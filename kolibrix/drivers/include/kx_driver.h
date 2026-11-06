#ifndef KX_DRIVER_H
#define KX_DRIVER_H

/*
 * KolibriX driver ABI draft, version 1.
 *
 * This header defines the planned boundary only. It is not yet a loadable
 * module ABI: the current KolibriOS-derived kernel does not expose this
 * interface. Keep structures fixed-width and versioned before implementation.
 */

#include <stdint.h>

#define KX_DRIVER_ABI_MAJOR 1u
#define KX_DRIVER_ABI_MINOR 0u

#define KX_DRIVER_CLASS_DISPLAY  1u
#define KX_DRIVER_CLASS_INPUT    2u
#define KX_DRIVER_CLASS_STORAGE  3u
#define KX_DRIVER_CLASS_NETWORK  4u
#define KX_DRIVER_CLASS_AUDIO    5u
#define KX_DRIVER_CLASS_TIMER    6u

#define KX_DRIVER_OK              0
#define KX_DRIVER_E_INVALID      -1
#define KX_DRIVER_E_UNSUPPORTED  -2
#define KX_DRIVER_E_NO_RESOURCE  -3
#define KX_DRIVER_E_IO           -4
#define KX_DRIVER_E_TIMEOUT      -5

typedef struct kx_device_id {
    uint16_t vendor_id;
    uint16_t device_id;
    uint8_t  bus_type;
    uint8_t  revision;
    uint16_t reserved;
} kx_device_id_t;

typedef struct kx_driver_info {
    uint32_t struct_size;
    uint16_t abi_major;
    uint16_t abi_minor;
    uint32_t driver_class;
    const char *name;
    const char *version;
} kx_driver_info_t;

/*
 * The kernel owns device resources. A driver receives only granted handles;
 * it must not assume unrestricted port or physical-memory access.
 */
typedef struct kx_device {
    uint32_t struct_size;
    kx_device_id_t id;
    uint32_t resource_handle;
    uint32_t flags;
} kx_device_t;

typedef struct kx_driver_ops {
    uint32_t struct_size;
    int32_t (*probe)(const kx_device_t *device);
    int32_t (*start)(kx_device_t *device);
    void    (*stop)(kx_device_t *device);
    int32_t (*suspend)(kx_device_t *device);
    int32_t (*resume)(kx_device_t *device);
} kx_driver_ops_t;

/* Each future driver exports one descriptor with this logical shape. */
typedef struct kx_driver_descriptor {
    kx_driver_info_t info;
    kx_driver_ops_t ops;
} kx_driver_descriptor_t;

#endif
