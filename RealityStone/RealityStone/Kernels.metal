//
//  Kernels.metal
//  RealityStone
//
//  Created by dely on 2018. 10. 19..
//  Copyright © 2018년 dely. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void pixelate(texture2d<float, access::read> inTexture [[texture(0)]],
//                     texture2d<float, access::read> inTexture2 [[texture(1)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
//                     device unsigned int *pixelSize [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]){
    
//    const float4 outputColor = float4(colorAtPixel.r, colorAtPixel.g, colorAtPixel.b, 1.0);
    const float4 colorAtPixel = inTexture.read(gid);
    outTexture.write(colorAtPixel, gid);
}

