pub const decay = DecayStruct.inner;
pub const normalize = NormalizeStruct.inner;

const DecayStruct = @import("./filters/decay.zig");
const NormalizeStruct = @import("./filters/normalize.zig");

pub const Error = DecayStruct.Error || NormalizeStruct.Error;
