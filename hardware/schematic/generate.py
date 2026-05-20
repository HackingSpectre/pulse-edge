"""Generate the Pulse Edge wearable schematic as PNG + SVG.

Produces hardware/schematic/pulse_edge.{png,svg}.

Run:
    cd hardware/schematic
    python3 generate.py
"""

from __future__ import annotations

from pathlib import Path

import schemdraw
import schemdraw.elements as elm

OUT_DIR = Path(__file__).resolve().parent
TITLE = "Pulse Edge — Wearable schematic (rev 0.1)"


def build() -> schemdraw.Drawing:
    d = schemdraw.Drawing(show=False, fontsize=10, lblofst=0.12)
    d.config(unit=2.0)

    # ─────────────────────────── POWER SECTION (top-left) ───────────────────
    bat = d.add(
        elm.Battery()
        .label("LiPo 3.7V\n400 mAh", loc="bottom")
        .at((0, 14))
        .right()
    )

    # TP4056 charger.
    tp = d.add(
        elm.Ic(
            pins=[
                elm.IcPin(name="BATP", side="L", anchorname="BATP", pin="1"),
                elm.IcPin(name="BATN", side="L", anchorname="BATN", pin="2"),
                elm.IcPin(name="OUTP", side="R", anchorname="OUTP", pin="3"),
                elm.IcPin(name="OUTN", side="R", anchorname="OUTN", pin="4"),
                elm.IcPin(name="USB",  side="T", anchorname="USB",  pin="5"),
            ],
            label="TP4056\nUSB-C charger",
            w=3,
            h=3,
        ).at((4, 14)).anchor("BATP")
    )
    d.add(elm.Line().at(bat.end).to(tp.BATP))

    # USB input label.
    d.add(elm.Line().at(tp.USB).up().length(1.0))
    d.add(elm.Label().label("USB-C\n(charging)", color="navy"))

    # GND from TP4056 BATN to ground.
    d.add(elm.Line().at(tp.BATN).down().length(1.4))
    d.add(elm.Ground().label("BAT−"))

    # VBAT bus to LDO.
    vbat_bus = (tp.OUTP[0] + 1.0, tp.OUTP[1])
    d.add(elm.Wire("-").at(tp.OUTP).to(vbat_bus))
    d.add(elm.Dot().at(vbat_bus))
    d.add(elm.Label().at(vbat_bus).label("VBAT", loc="top", color="darkred"))
    # GND from TP4056 OUTN.
    d.add(elm.Line().at(tp.OUTN).down().length(0.8))
    d.add(elm.Ground())

    # MCP1700 LDO.
    ldo = d.add(
        elm.Ic(
            pins=[
                elm.IcPin(name="VIN",  side="L", anchorname="VIN"),
                elm.IcPin(name="GND",  side="B", anchorname="GND"),
                elm.IcPin(name="VOUT", side="R", anchorname="VOUT"),
            ],
            label="MCP1700\n3V3 LDO",
            w=2.6,
            h=2,
        ).at((vbat_bus[0] + 0.5, vbat_bus[1])).anchor("VIN")
    )
    d.add(elm.Line().at(vbat_bus).to(ldo.VIN))
    # Decoupling caps on input and output.
    d.add(elm.Capacitor().at(ldo.VIN).down().length(1.4).label("1µF", loc="bottom"))
    d.add(elm.Ground())
    d.add(elm.Capacitor().at(ldo.VOUT).down().length(1.4).label("1µF", loc="bottom"))
    d.add(elm.Ground())
    # LDO GND pin to ground.
    d.add(elm.Line().at(ldo.GND).down().length(0.6))
    d.add(elm.Ground())

    # 3V3 rail (horizontal at top).
    rail3v3 = ldo.VOUT
    d.add(elm.Line().at(rail3v3).right().length(11.5))
    rail_end = d.here
    d.add(elm.Dot().at(rail3v3))
    d.add(elm.Label().at(rail3v3).label("3V3", loc="top", color="darkgreen"))

    # ─────────────────────────── ESP32-WROOM (centre) ────────────────────────
    esp_pins = [
        elm.IcPin(name="3V3",   side="L", anchorname="VDD",  pin="2"),
        elm.IcPin(name="EN",    side="L", anchorname="EN",   pin="3"),
        elm.IcPin(name="GND",   side="L", anchorname="GND1", pin="1"),
        elm.IcPin(name="GPIO0\nBOOT", side="L", anchorname="IO0", pin="25"),
        elm.IcPin(name="GPIO2\nLED",  side="L", anchorname="IO2", pin="24"),
        elm.IcPin(name="GPIO21\nSDA", side="R", anchorname="IO21", pin="33"),
        elm.IcPin(name="GPIO22\nSCL", side="R", anchorname="IO22", pin="36"),
        elm.IcPin(name="GPIO4\n1Wire",  side="R", anchorname="IO4",  pin="26"),
        elm.IcPin(name="GPIO25\nVIB",   side="R", anchorname="IO25", pin="10"),
        elm.IcPin(name="GPIO34\nVBSNS", side="R", anchorname="IO34", pin="6"),
        elm.IcPin(name="GPIO19\nMAXINT",side="R", anchorname="IO19", pin="31"),
        elm.IcPin(name="GPIO23\nMPUINT",side="R", anchorname="IO23", pin="37"),
        elm.IcPin(name="TX0", side="B", anchorname="TX", pin="34"),
        elm.IcPin(name="RX0", side="B", anchorname="RX", pin="35"),
    ]
    esp = d.add(
        elm.Ic(
            pins=esp_pins,
            label="ESP32-WROOM-32E",
            w=6.5,
            h=10,
            plblofst=0.5,
        ).at((6.5, 6.5)).anchor("VDD")
    )

    # 3V3 from rail down to ESP VDD.
    d.add(elm.Wire("-|").at(rail_end).to(esp.absanchors["VDD"]))

    # GND.
    d.add(elm.Line().at(esp.absanchors["GND1"]).left().length(1.0))
    d.add(elm.Ground())

    # EN: 10k pull-up + 100n cap to GND (reset network).
    d.add(elm.Resistor().at(esp.absanchors["EN"]).left().length(1.5).label("10k", loc="bottom"))
    en_pull_top = d.here
    d.add(elm.Wire("|-").to(rail_end))
    d.add(elm.Capacitor().at(esp.absanchors["EN"]).down().length(1.0).label("100n", loc="bottom"))
    d.add(elm.Ground())

    # GPIO0 pull-up (normal boot strap).
    d.add(elm.Resistor().at(esp.absanchors["IO0"]).left().length(1.5).label("10k", loc="bottom"))
    d.add(elm.Wire("|-").to(rail_end))

    # ─────────────────────────── STATUS LED on GPIO2 ─────────────────────────
    d.add(elm.Resistor().at(esp.absanchors["IO2"]).left().length(1.5).label("330", loc="bottom"))
    d.add(elm.LED().left().length(1.4).label("STATUS", loc="bottom"))
    d.add(elm.Ground())

    # ─────────────────────────── I²C BUS + PULL-UPS ──────────────────────────
    sda_pin = esp.absanchors["IO21"]
    scl_pin = esp.absanchors["IO22"]

    # SDA pull-up + bus run to the right.
    d.add(elm.Line().at(sda_pin).right().length(1.5))
    sda_node = d.here
    d.add(elm.Dot().at(sda_node))
    d.add(elm.Resistor().up().length(2.5).label("4.7k", loc="bottom"))
    d.add(elm.Wire("|-").to(rail_end))

    # SCL pull-up + bus run.
    d.add(elm.Line().at(scl_pin).right().length(2.5))
    scl_node = d.here
    d.add(elm.Dot().at(scl_node))
    d.add(elm.Resistor().up().length(3.5).label("4.7k", loc="bottom"))
    d.add(elm.Wire("|-").to(rail_end))

    # Bus continues right to sensors.
    d.add(elm.Line().at(sda_node).right().length(2.4))
    sda_bus_end = d.here
    d.add(elm.Line().at(scl_node).right().length(2.4))
    scl_bus_end = d.here

    # ─────────────────────────── MAX30102 (top right) ────────────────────────
    max302 = d.add(
        elm.Ic(
            pins=[
                elm.IcPin(name="VIN", side="L", anchorname="VIN"),
                elm.IcPin(name="SDA", side="L", anchorname="SDA"),
                elm.IcPin(name="SCL", side="L", anchorname="SCL"),
                elm.IcPin(name="INT", side="L", anchorname="INT"),
                elm.IcPin(name="GND", side="B", anchorname="GND"),
            ],
            label="MAX30102\nPPG / SpO₂",
            w=2.6,
            h=3.4,
        ).at((sda_bus_end[0] + 1.6, sda_bus_end[1] + 2.2)).anchor("VIN")
    )
    d.add(elm.Wire("-|").at(rail_end).to(max302.VIN))
    d.add(elm.Wire("|-").at(sda_bus_end).to(max302.SDA))
    d.add(elm.Wire("|-").at(scl_bus_end).to(max302.SCL))
    d.add(elm.Wire("|-").at(esp.absanchors["IO19"]).to(max302.INT))
    d.add(elm.Line().at(max302.GND).down().length(0.8))
    d.add(elm.Ground())

    # ─────────────────────────── MPU6050 (middle right) ──────────────────────
    mpu = d.add(
        elm.Ic(
            pins=[
                elm.IcPin(name="VCC", side="L", anchorname="VCC"),
                elm.IcPin(name="SDA", side="L", anchorname="SDA"),
                elm.IcPin(name="SCL", side="L", anchorname="SCL"),
                elm.IcPin(name="AD0", side="R", anchorname="AD0"),
                elm.IcPin(name="INT", side="R", anchorname="INT"),
                elm.IcPin(name="GND", side="B", anchorname="GND"),
            ],
            label="MPU6050\n6-axis IMU",
            w=2.6,
            h=3.4,
        ).at((sda_bus_end[0] + 1.6, sda_bus_end[1] - 2.0)).anchor("VCC")
    )
    d.add(elm.Wire("-|").at(rail_end).to(mpu.VCC))
    d.add(elm.Wire("|-").at(sda_bus_end).to(mpu.SDA))
    d.add(elm.Wire("|-").at(scl_bus_end).to(mpu.SCL))
    # AD0 → GND (sets address 0x68).
    d.add(elm.Line().at(mpu.AD0).right().length(0.8))
    d.add(elm.Ground())
    # INT → ESP32 GPIO23.
    d.add(elm.Line().at(mpu.INT).right().length(0.6))
    int_corner = d.here
    d.add(elm.Wire("|-").at(esp.absanchors["IO23"]).to(int_corner))
    d.add(elm.Line().at(mpu.GND).down().length(0.8))
    d.add(elm.Ground())

    # ─────────────────────────── DS18B20 (1-Wire, bottom right) ──────────────
    ds = d.add(
        elm.Ic(
            pins=[
                elm.IcPin(name="VDD", side="T", anchorname="VDD"),
                elm.IcPin(name="DQ",  side="L", anchorname="DQ"),
                elm.IcPin(name="GND", side="B", anchorname="GND"),
            ],
            label="DS18B20\nSkin temp",
            w=2.4,
            h=2.4,
        ).at((sda_bus_end[0] + 1.6, sda_bus_end[1] - 5.5)).anchor("DQ")
    )
    d.add(elm.Wire("-|").at(rail_end).to(ds.VDD))
    # DQ pull-up + line to GPIO4.
    dq = ds.DQ
    d.add(elm.Resistor().at(dq).up().length(1.5).label("4.7k", loc="bottom"))
    d.add(elm.Wire("|-").to(rail_end))
    d.add(elm.Line().at(dq).left().length(2.0))
    dq_corner = d.here
    d.add(elm.Wire("|-").at(esp.absanchors["IO4"]).to(dq_corner))
    d.add(elm.Line().at(ds.GND).down().length(0.6))
    d.add(elm.Ground())

    # ─────────────────────────── VIBRATION MOTOR DRIVER ──────────────────────
    # GPIO25 → 1k → base of NPN. Motor between VBAT and collector with flyback.
    g25 = esp.absanchors["IO25"]
    d.add(elm.Resistor().at(g25).right().length(1.5).label("1k", loc="bottom"))
    base_pt = d.here
    q1 = d.add(
        elm.BjtNpn(circle=True).right().anchor("base").at(base_pt).label("Q1\n2N3904", loc="bottom")
    )
    d.add(elm.Line().at(q1.emitter).down().length(0.8))
    d.add(elm.Ground())

    # Motor + flyback.
    mtop = (q1.collector[0], q1.collector[1] + 2.0)
    d.add(elm.Line().at(q1.collector).up().length(2.0))
    d.add(elm.Dot().at(mtop))
    d.add(elm.Resistor().at(mtop).up().length(1.6).label("M\nvib motor", loc="bottom"))
    motor_top_pt = d.here
    d.add(elm.Line().at(motor_top_pt).right().length(1.2))
    d.add(elm.Label().label("VBAT", color="darkred"))
    d.add(elm.Diode().at(q1.collector).up().length(2.0).reverse().label("D1\n1N4148", loc="bottom"))

    # ─────────────────────────── BATTERY VOLTAGE SENSE (GPIO34) ──────────────
    g34 = esp.absanchors["IO34"]
    d.add(elm.Line().at(g34).right().length(1.5))
    div_node = d.here
    d.add(elm.Dot().at(div_node))
    d.add(elm.Resistor().up().length(1.7).label("100k", loc="bottom"))
    d.add(elm.Label().label("VBAT", color="darkred", loc="top"))
    d.add(elm.Resistor().at(div_node).down().length(1.7).label("100k", loc="bottom"))
    d.add(elm.Ground())

    # ─────────────────────────── PROGRAMMING / UART HEADER ───────────────────
    tx = esp.absanchors["TX"]
    rx = esp.absanchors["RX"]
    d.add(elm.Line().at(tx).down().length(1.2))
    d.add(elm.Line().at(rx).down().length(1.2))
    d.add(
        elm.Label()
        .at((tx[0] + 0.6, tx[1] - 0.7))
        .label("To CP2102N USB-UART\n(programming header)", color="navy")
    )

    # ─────────────────────────── TITLE BLOCK ─────────────────────────────────
    d.add(
        elm.Label()
        .at((6.5, 19.0))
        .label(TITLE, fontsize=14)
    )
    d.add(
        elm.Label()
        .at((6.5, 18.4))
        .label(
            "ESP32-WROOM-32E + MAX30102 + DS18B20 + MPU6050",
            color="gray",
            fontsize=10,
        )
    )
    d.add(
        elm.Label()
        .at((6.5, 17.9))
        .label(
            "I²C: SDA=GPIO21 / SCL=GPIO22 (4.7k pull-ups)   •   "
            "1-Wire: GPIO4 (4.7k pull-up)   •   VIB: GPIO25 → NPN",
            color="gray",
            fontsize=9,
        )
    )

    return d


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    d = build()
    png = OUT_DIR / "pulse_edge.png"
    svg = OUT_DIR / "pulse_edge.svg"
    d.save(str(png), dpi=200)
    d.save(str(svg))
    print(f"wrote {png}")
    print(f"wrote {svg}")


if __name__ == "__main__":
    main()
