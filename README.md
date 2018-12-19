# Device Tree for Nokia 6.1 (PL2)

The Nokia 6 (codenamed _"PL2"_) is a mid-range smartphone from Nokia.
It was released in April 2018.

| Basic                   | Spec Sheet                                                                                                                     |
| -----------------------:|:------------------------------------------------------------------------------------------------------------------------------ |
| CPU                     | Octa-core 2.2 GHz Cortex-A53                                                                                                   |
| Chipset                 | Qualcomm SDM630 Snapdragon 660                                                                                                 |
| GPU                     | Adreno 630                                                                                                                     |
| Memory                  | 3/4 GB RAM                                                                                                                     |
| Shipped Android Version | 8.1                                                                                                                            |
| Storage                 | 32/64 GB                                                                                                                       |
| Battery                 | Non-removable Li-Po 3000 mAh battery                                                                                           |
| Display                 | 1080 x 1920 pixels, 16:9 ratio (~403 ppi density)                                                                              |
| Camera (Back)           | 16 MP, f/2.0, 27mm (wide), 1.0µm, PDAF, Zeiss optics, dual-LED dual-tone flash, panorama, HDR, 2160p@30fps, 1080p@30fps        |
| Camera (Front)          | 8 MP, f/2.0, 1/4", 1.12µm, 1080p@30fps                                                                                         |

Copyright 2018 - The LineageOS Project.

![Nokia 6.1](https://cdn2.gsmarena.com/vv/pics/nokia/nokia-6-2018-1.jpg)


## Build instructions

```
# Compiling
$ . build/envsetup.sh
$ lunch omni_PL2-eng
$ make -jx recoveryimage //replace x in -jx with number of cores you want to allot for compilation

```

**Kerenl Source**: https://github.com/nokia-dev/android_kernel_nokia_sdm660
