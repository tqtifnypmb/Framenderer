/*
 3x3 median filter, adapted from "A Fast, Small-Radius GPU Median Filter" by Morgan McGuire in ShaderX6
 http://graphics.cs.williams.edu/papers/MedianShaderX6/
 
 Morgan McGuire and Kyle Whitson
 Williams College
 
 Register allocation tips by Victor Huang Xiaohuang
 University of Illinois at Urbana-Champaign
 
 http://graphics.cs.williams.edu
 
 
 Copyright (c) Morgan McGuire and Williams College, 2006
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#version 300 es

precision mediump float;

in vec2 fLTTextCoor;
in vec2 fMTTextCoor;
in vec2 fRTTextCoor;
in vec2 fLMTextCoor;
in vec2 fCenterTextCoor;
in vec2 fRMTextCoor;
in vec2 fLBTextCoor;
in vec2 fMBTextCoor;
in vec2 fRBTextCoor;

uniform sampler2D firstInput;

out vec4 color;

#define s2(a, b)				temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)			s2(a, b); s2(a, c);
#define mx3(a, b, c)			s2(b, c); s2(a, c);

#define mnmx3(a, b, c)			mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)		s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)	s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges

void main() {
    vec3 v[6];
    
    v[0] = texture(firstInput, fLBTextCoor).rgb;
    v[1] = texture(firstInput, fRTTextCoor).rgb;
    v[2] = texture(firstInput, fLTTextCoor).rgb;
    v[3] = texture(firstInput, fRBTextCoor).rgb;
    v[4] = texture(firstInput, fLMTextCoor).rgb;
    v[5] = texture(firstInput, fRMTextCoor).rgb;
    
    vec3 temp;
    
    mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
    
    v[5] = texture(firstInput, fMBTextCoor).rgb;
    
    mnmx5(v[1], v[2], v[3], v[4], v[5]);
    
    v[5] = texture(firstInput, fMTTextCoor).rgb;
    
    mnmx4(v[2], v[3], v[4], v[5]);
    
    v[5] = texture(firstInput, fCenterTextCoor).rgb;
    
    mnmx3(v[3], v[4], v[5]);
    
    color = vec4(v[4], 1.0);
}
