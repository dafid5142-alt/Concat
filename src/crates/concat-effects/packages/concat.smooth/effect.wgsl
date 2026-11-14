struct Params { amount: f32 }

// A bilateral blur on the display level: each pixel becomes the average of
// its neighbours that are nearly its own colour, so the speckle a low
// bitrate leaves in a sky or on a wall is averaged away while an edge, whose
// two sides are far apart in colour, is left where it was. `amount` widens
// both what counts as near in place and what counts as near in colour; at
// its top a face or a sky comes out as smooth as a drawing.
fn effect(uv: vec2<f32>) -> vec4<f32> {
    let t = texel();
    let c = sample(uv);
    let reach = 1.0 + params.amount * 1.5;
    let tolerance = 0.03 + params.amount * 0.12;
    var sum = vec3<f32>(0.0);
    var total = 0.0;
    for (var y: i32 = -3; y <= 3; y++) {
        for (var x: i32 = -3; x <= 3; x++) {
            let s = sample(uv + vec2<f32>(f32(x), f32(y)) * t * reach).rgb;
            let d = s - c.rgb;
            let place = exp(-f32(x * x + y * y) / 8.0);
            let colour = exp(-dot(d, d) / (2.0 * tolerance * tolerance));
            sum += s * place * colour;
            total += place * colour;
        }
    }
    return vec4<f32>(sum / total, c.a);
}
