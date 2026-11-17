#!/usr/bin/env node
// Deterministically render a small Yfit mark PNG without external graphics libraries.
const fs = require('node:fs');
const zlib = require('node:zlib');
const w = 256, h = 256;
const rows = [];
const polys = [
  { p: [[62,67],[98,67],[128,121],[158,67],[194,67],[146,151],[146,191],[110,191],[110,151]], c: [244,192,0,255] },
];
function inside(x,y,p) { let c=false; for(let i=0,j=p.length-1;i<p.length;j=i++) { const a=p[i],b=p[j]; if(((a[1]>y)!==(b[1]>y))&&(x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0])) c=!c; } return c; }
function crc32(buf) { let c=0xffffffff; for(const v of buf) { c^=v; for(let k=0;k<8;k++) c=(c>>>1)^((c&1)?0xedb88320:0); } return (c^0xffffffff)>>>0; }
function chunk(type,data) { const t=Buffer.from(type), len=Buffer.alloc(4), crc=Buffer.alloc(4); len.writeUInt32BE(data.length); crc.writeUInt32BE(crc32(Buffer.concat([t,data]))); return Buffer.concat([len,t,data,crc]); }
for(let y=0;y<h;y++) { const row=Buffer.alloc(1+w*4); for(let x=0;x<w;x++) { let rgba=[17,24,39,0]; const dx=Math.max(48-x,0,x-208),dy=Math.max(48-y,0,y-208); if(dx*dx+dy*dy<=36*36 || (x>=48&&x<=208&&y>=48&&y<=208)) rgba=[17,24,39,255]; for(const shape of polys) if(inside(x+.5,y+.5,shape.p)) rgba=shape.c; if((x-191)**2+(y-190)**2<=17**2) rgba=[34,197,94,255]; row.set(rgba,1+x*4); } rows.push(row); }
const ihdr=Buffer.alloc(13); ihdr.writeUInt32BE(w,0); ihdr.writeUInt32BE(h,4); ihdr[8]=8; ihdr[9]=6;
const png=Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',ihdr),chunk('IDAT',zlib.deflateSync(Buffer.concat(rows),{level:9})),chunk('IEND',Buffer.alloc(0))]);
fs.writeFileSync(process.argv[2] || 'yfit-mark.png',png);
