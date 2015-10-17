# This file controls streaming midi data to a device on your system. Windows only, until someone wants to port it to other systems and
# submit a pull request.

const CALLBACK_NULL = uint32(0x00000000)

immutable SZPName
    c1::UInt8
    c2::UInt8
    c3::UInt8
    c4::UInt8
    c5::UInt8
    c6::UInt8
    c7::UInt8
    c8::UInt8
    c9::UInt8
    c10::UInt8
    c11::UInt8
    c12::UInt8
    c13::UInt8
    c14::UInt8
    c15::UInt8
    c16::UInt8
    c17::UInt8
    c18::UInt8
    c19::UInt8
    c20::UInt8
    c21::UInt8
    c22::UInt8
    c23::UInt8
    c24::UInt8
    c25::UInt8
    c26::UInt8
    c27::UInt8
    c28::UInt8
    c29::UInt8
    c30::UInt8
    c31::UInt8
    c32::UInt8
end

tostring(x::SZPName) = bytestring(pointer(ASCIIString([x.(z) for z in 1:length(names(x))])))

type MidiOutCaps
    wMid::UInt16
    wPid::UInt16
    vDriverVersion::UInt32
    szPname::NTuple{32, UInt8}
    wTechnology::UInt16
    wVoices::UInt16
    wNotes::UInt16
    wChannelMask::UInt16
    dwSupport::UInt32

    #MidiOutCaps() = new(0, 0, 0,        SZPName(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),        0, 0, 0, 0, 0)
    MidiOutCaps() = new(0, 0, 0, ntuple(x -> 0, 32), 0, 0, 0, 0, 0)
end

function getoutputdevices()
    numberofdevices = ccall( (:midiOutGetNumDevs, :Winmm), stdcall, Int32, ())
    results = Array(Any, 0)

    for i in [0:numberofdevices-1;]
        output_struct = Ref{MidiOutCaps}(MidiOutCaps())
        err = ccall(
            (:midiOutGetDevCapsA, :Winmm),
            stdcall,
            UInt32,
            (Ptr{UInt32}, Ref{MidiOutCaps}, UInt32),
            Ptr{UInt32}(i), # Why Ptr instead of ref?
            output_struct,
            sizeof(output_struct[])
        )
        push!(results, (bytestring(Ptr{Cchar}(pointer_from_objref(output_struct[].szPname))), output_struct[].wMid, output_struct[].wPid))
    end

    results
end

const CALLBACK_NULL = uint32(0x00000000)
function openoutputdevice(id::UInt32)
    handle = Ref{Cint}(1)

    err = ccall((:midiOutOpen, :Winmm), stdcall,
        UInt32,
        (Ref{Cint}, UInt32, Ptr{UInt32}, Ptr{UInt32}, UInt32),
        Ref{Cint}(handle), id, C_NULL, C_NULL, CALLBACK_NULL)

    println(hex(err, 4))
    println(hex(handle[], 4))
    handle
end

function closeoutputdevice(id::UInt32)
    handle = uint32(0)

    ccall((:midiOutClose, :Winmm), stdcall,
        UInt32,
        (UInt32,),
        id)
end


#=
    MMRESULT midiOutOpen(
        LPHMIDIOUT lphmo, // 32?
        UINT       uDeviceID,
        DWORD_PTR  dwCallback,
        DWORD_PTR  dwCallbackInstance,
        DWORD      dwFlags
   );
=#

function initstream(device)

end