# Mid-flight solar Li-Pol charging for UAV

_Note: This README was updated on April 6, 2026. The project source code has not been modified since early 2020._

In the academic year of 2019/2020, Piotr Lazarek and I have worked on
the design of efficient power-management system to load Li-Pol
battery cell powering an Unmanned Air Vehicle from solar panels
mid-flight. This project was the basis of our participation
in the European Union Contest for Young Scientists (edition 2019/2020).
The context is that that year we individually received funding from
Dulwich College in London to study at their A-Level course
with free tuition and accomodation. This was organized 
from start to end by the Polish Children's fund. The work was
done while together at Dulwich College.

For the details of the design, please see `pl_eucys-poster.pdf`,
which was our contribution for EUCYS. This is the original
version of the poster in Polish.

## Prerequisites

Install required tools:

```bash
sudo apt install gcc-arm-none-eabi gdb-multiarch openocd
```

Required binaries:
- `arm-none-eabi-gcc`
- `arm-none-eabi-objcopy`
- `gdb-multiarch`
- `openocd`

## Build

Build for STM32L011K4Tx:

```bash
make l011k4tx
```

Build for STM32L011F3Ux:

```bash
make l011f3ux
```

Build artifacts:
- `dest/main.elf`
- `dest/main.hex`

## Flash Firmware

1. Connect the board using ST-Link.
2. Start OpenOCD in terminal 1:

```bash
make con
```

3. Flash from terminal 2.

For K4:

```bash
make flash-l011k4tx
```

For F3:

```bash
make flash-l011f3ux
```

## Debug

1. Connect the board using ST-Link.
2. Start OpenOCD in terminal 1:

```bash
make con
```

3. Start GDB in terminal 2.

For K4:

```bash
make debug-l011k4tx
```

For F3:

```bash
make debug-l011f3ux
```

Useful GDB commands:

```gdb
break main
continue
next
step
info registers
```

## Notes

- `make` without a target is intentionally blocked.
- Always choose an explicit board target.
- Clean build outputs with:

```bash
make clean
```
