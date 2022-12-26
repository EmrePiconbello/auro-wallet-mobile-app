#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

use crate::api::*;
use flutter_rust_bridge::*;

// Section: imports

// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_getAddressFromSecretHex(port_: i64, secret_hex: *mut wire_uint_8_list) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "getAddressFromSecretHex",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_secret_hex = secret_hex.wire2api();
            move |task_callback| Ok(getAddressFromSecretHex(api_secret_hex))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_signPayment(
    port_: i64,
    secret_hex: *mut wire_uint_8_list,
    to: *mut wire_uint_8_list,
    amount: u64,
    fee: u64,
    nonce: u32,
    valid_until: u32,
    memo: *mut wire_uint_8_list,
    network_id: u8,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "signPayment",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_secret_hex = secret_hex.wire2api();
            let api_to = to.wire2api();
            let api_amount = amount.wire2api();
            let api_fee = fee.wire2api();
            let api_nonce = nonce.wire2api();
            let api_valid_until = valid_until.wire2api();
            let api_memo = memo.wire2api();
            let api_network_id = network_id.wire2api();
            move |task_callback| {
                Ok(signPayment(
                    api_secret_hex,
                    api_to,
                    api_amount,
                    api_fee,
                    api_nonce,
                    api_valid_until,
                    api_memo,
                    api_network_id,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_signDelegation(
    port_: i64,
    secret_hex: *mut wire_uint_8_list,
    to: *mut wire_uint_8_list,
    fee: u64,
    nonce: u32,
    valid_until: u32,
    memo: *mut wire_uint_8_list,
    network_id: u8,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "signDelegation",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_secret_hex = secret_hex.wire2api();
            let api_to = to.wire2api();
            let api_fee = fee.wire2api();
            let api_nonce = nonce.wire2api();
            let api_valid_until = valid_until.wire2api();
            let api_memo = memo.wire2api();
            let api_network_id = network_id.wire2api();
            move |task_callback| {
                Ok(signDelegation(
                    api_secret_hex,
                    api_to,
                    api_fee,
                    api_nonce,
                    api_valid_until,
                    api_memo,
                    api_network_id,
                ))
            }
        },
    )
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: wrapper structs

// Section: static checks

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        if self.is_null() {
            None
        } else {
            Some(self.wire2api())
        }
    }
}

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<u32> for u32 {
    fn wire2api(self) -> u32 {
        self
    }
}

impl Wire2Api<u64> for u64 {
    fn wire2api(self) -> u64 {
        self
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: impl IntoDart

impl support::IntoDart for SignatureData {
    fn into_dart(self) -> support::DartCObject {
        vec![self.field.into_dart(), self.scalar.into_dart()].into_dart()
    }
}
impl support::IntoDartExceptPrimitive for SignatureData {}

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturnStruct(val: support::WireSyncReturnStruct) {
    unsafe {
        let _ = support::vec_from_leak_ptr(val.ptr, val.len);
    }
}
