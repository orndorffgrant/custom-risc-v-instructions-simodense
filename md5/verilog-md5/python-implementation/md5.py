"""
// : All variables are unsigned 32 bit and wrap modulo 2^32 when calculating
var int s[64], K[64]
var int i

// s specifies the per-round shift amounts
s[ 0..15] := { 7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22 }
s[16..31] := { 5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20 }
s[32..47] := { 4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23 }
s[48..63] := { 6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21 }

// Use binary integer part of the sines of integers (Radians) as constants:
for i from 0 to 63 do
    K[i] := floor(232 × abs(sin(i + 1)))
end for
// (Or just use the following precomputed table):
K[ 0.. 3] := { 0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee }
K[ 4.. 7] := { 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501 }
K[ 8..11] := { 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be }
K[12..15] := { 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821 }
K[16..19] := { 0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa }
K[20..23] := { 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8 }
K[24..27] := { 0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed }
K[28..31] := { 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a }
K[32..35] := { 0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c }
K[36..39] := { 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70 }
K[40..43] := { 0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05 }
K[44..47] := { 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665 }
K[48..51] := { 0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039 }
K[52..55] := { 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1 }
K[56..59] := { 0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1 }
K[60..63] := { 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391 }

// Initialize variables:
var int a0 := 0x67452301   // A
var int b0 := 0xefcdab89   // B
var int c0 := 0x98badcfe   // C
var int d0 := 0x10325476   // D

// Pre-processing: adding a single 1 bit
append "1" bit to message<    
 // Notice: the input bytes are considered as bit strings,
 //  where the first bit is the most significant bit of the byte.[51]

// Pre-processing: padding with zeros
append "0" bit until message length in bits ≡ 448 (mod 512)

// Notice: the two padding steps above are implemented in a simpler way
 //  in implementations that only work with complete bytes: append 0x80
 //  and pad with 0x00 bytes so that the message length in bytes ≡ 56 (mod 64).

append original length in bits mod 264 to message

// Process the message in successive 512-bit chunks:
for each 512-bit chunk of padded message do
    break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
    // Initialize hash value for this chunk:
    var int A := a0
    var int B := b0
    var int C := c0
    var int D := d0
    // Main loop:
    for i from 0 to 63 do
        var int F, g
        if 0 ≤ i ≤ 15 then
            F := (B and C) or ((not B) and D)
            g := i
        else if 16 ≤ i ≤ 31 then
            F := (D and B) or ((not D) and C)
            g := (5×i + 1) mod 16
        else if 32 ≤ i ≤ 47 then
            F := B xor C xor D
            g := (3×i + 5) mod 16
        else if 48 ≤ i ≤ 63 then
            F := C xor (B or (not D))
            g := (7×i) mod 16
        // Be wary of the below definitions of a,b,c,d
        F := F + A + K[i] + M[g]  // M[g] must be a 32-bit block
        A := D
        D := C
        C := B
        B := B + leftrotate(F, s[i])
    end for
    // Add this chunk's hash to result so far:
    a0 := a0 + A
    b0 := b0 + B
    c0 := c0 + C
    d0 := d0 + D
end for
"""

shift_amounts = [
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
]

K = [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,

    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,

    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,

    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
]

a0 = 0x67452301
b0 = 0xefcdab89
c0 = 0x98badcfe
d0 = 0x10325476


def leftrotate(val, rotate_amount):
    shifted_left = (val << rotate_amount) & 0xFFFFFFFF
    shift_right_amount = 32 - rotate_amount
    shifted_right = (val >> shift_right_amount) & 0xFFFFFFFF
    final = (shifted_left | shifted_right) & 0xFFFFFFFF
    return final


def md5_round_type_1(a, b, c, d, k, shift_amount, round_num, message):
    f_one = (b & c) | ((~b) & d)
    g = round_num

    f_two = (f_one + a + k + message[g]) & 0xFFFFFFFF
    a = d
    d = c
    c = b
    b = (b + leftrotate(f_two, shift_amount)) & 0xFFFFFFFF

    return (a, b, c, d)

def md5_round_type_2(a, b, c, d, k, shift_amount, round_num, message):
    f_one = (d & b) | ((~d) & c)
    g = ((round_num*5) + 1) % 16
    f_two = (f_one + a + k + message[g]) & 0xFFFFFFFF
    a = d
    d = c
    c = b
    b = (b + leftrotate(f_two, shift_amount)) & 0xFFFFFFFF

    return (a, b, c, d)

def md5_round_type_3(a, b, c, d, k, shift_amount, round_num, message):
    f_one = (b ^ c) ^ d
    g = ((round_num*3) + 5) % 16
    f_two = (f_one + a + k + message[g]) & 0xFFFFFFFF
    a = d
    d = c
    c = b
    b = (b + leftrotate(f_two, shift_amount)) & 0xFFFFFFFF

    return (a, b, c, d)

def md5_round_type_4(a, b, c, d, k, shift_amount, round_num, message):
    f_one = c ^ (b | ~d)
    g = (round_num*7) % 16
    f_two = (f_one + a + k + message[g]) & 0xFFFFFFFF
    a = d
    d = c
    c = b
    b = (b + leftrotate(f_two, shift_amount)) & 0xFFFFFFFF

    return (a, b, c, d)


def md5_rounds_1_through_16(a, b, c, d, message):
    k = K[0:16]
    shifts = shift_amounts[0:16]
    for i in range(16):
        a, b, c, d = md5_round_type_1(a, b, c, d, k[i], shifts[i], i, message)
    return (a, b, c, d)

def md5_rounds_17_through_32(a, b, c, d, message):
    k = K[16:32]
    shifts = shift_amounts[16:32]
    for i in range(16):
        a, b, c, d = md5_round_type_2(a, b, c, d, k[i], shifts[i], i, message)
    return (a, b, c, d)

def md5_rounds_33_through_48(a, b, c, d, message):
    k = K[32:48]
    shifts = shift_amounts[32:48]
    for i in range(16):
        a, b, c, d = md5_round_type_3(a, b, c, d, k[i], shifts[i], i, message)
    return (a, b, c, d)

def md5_rounds_49_through_64(a, b, c, d, message):
    k = K[48:64]
    shifts = shift_amounts[48:64]
    for i in range(16):
        a, b, c, d = md5_round_type_4(a, b, c, d, k[i], shifts[i], i, message)
    return (a, b, c, d)

def md5_chunk(message):
    a0 = 0x67452301
    b0 = 0xefcdab89
    c0 = 0x98badcfe
    d0 = 0x10325476
    a, b, c, d = md5_rounds_1_through_16(a0, b0, c0, d0, message)
    a, b, c, d = md5_rounds_17_through_32(a, b, c, d, message)
    a, b, c, d = md5_rounds_33_through_48(a, b, c, d, message)
    a, b, c, d = md5_rounds_49_through_64(a, b, c, d, message)
    return (
        (a0 + a) & 0xffffffff,
        (b0 + b) & 0xffffffff,
        (c0 + c) & 0xffffffff,
        (d0 + d) & 0xffffffff,
    )

message = [
    0x6c6c6548,
    0x4e45206f,
    0x30384d50,
    0x54202138,
    0x20736968,
    0x6d207369,
    0x444d2079,
    0x6d692035,
    0x6d656c70,
    0x61746e65,
    0x6e6f6974,
    0x206e6920,
    0x69726576,
    0x80676f6c,
    0x000001b8,
    0x00000000,
]

a, b, c, d = md5_round_type_1(a0, b0, c0, d0, K[0], shift_amounts[0], 0, message)
print("round type 1")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_round_type_2(a0, b0, c0, d0, K[0], shift_amounts[0], 0, message)
print("round type 2")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_round_type_3(a0, b0, c0, d0, K[0], shift_amounts[0], 0, message)
print("round type 3")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_round_type_4(a0, b0, c0, d0, K[0], shift_amounts[0], 0, message)
print("round type 4")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_rounds_1_through_16(a0, b0, c0, d0, message)
print("rounds 1-16")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_rounds_17_through_32(a0, b0, c0, d0, message)
print("rounds 17-32")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_rounds_33_through_48(a0, b0, c0, d0, message)
print("rounds 33-48")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_rounds_49_through_64(a0, b0, c0, d0, message)
print("rounds 49-64")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

a, b, c, d = md5_chunk(message)
print("md5")
print("a: " + hex(a))
print("b: " + hex(b))
print("c: " + hex(c))
print("d: " + hex(d))

import hashlib
# reference
test_string = b"Hello ENPM808! This is my MD5 implementation in verilog"
print("message length in hex: " + hex(len(test_string) * 8))
ref = hashlib.md5(test_string)
print("md5 ref hex: " + ref.hexdigest())
test_string = list(test_string) + [0x80, 0xb8, 0x01, 0, 0, 0, 0, 0, 0]

print("padded: ", end='')
for i in range(0, len(test_string), 4):
    if i % 16 == 0:
        print()
    bs = list(test_string[i:i+4])
    bs.reverse()
    print("0x{:02x}{:02x}{:02x}{:02x}, ".format(*bs), end='')

print()
