// Programmed by Euntae Bae

package MD5;

import ISA_Decls :: *;
import Vector :: *;
/*
 typedef enum {Identifier1, Identifier2, ... IdentifierN} EnumName
     deriving (Eq, Bits);
*/
typedef enum { MD5_INIT, MD5_STEP } MD5State deriving (Bits, Eq);

function Bit #(32) toLE32(Bit #(32) num);
   return { num[7:0], num[15:8], num[23:16], num[31:24] };
endfunction

function Bit #(64) toLE64(Bit #(64) num);
   return { num[7:0], num[15:8], num[23:16], num[31:24], num[39:32], num[47:40], num[55:48], num[63:56] };
endfunction

function Bit#(32) rotateLeft(Bit #(32) num, Bit #(32) shamt);
   Bit#(32) rot1, rot2;
   rot1 = num << shamt;
   rot2 = num >> (32 - shamt);
   return (rot1 | rot2);
endfunction

function Bit #(32) genK(Bit #(32) sel);
    return case (sel)
        0: 32'hd76aa478;
        1: 32'he8c7b756;
        2: 32'h242070db;
        3: 32'hc1bdceee;
        4: 32'hf57c0faf;
        5: 32'h4787c62a;
        6: 32'ha8304613;
        7: 32'hfd469501;
        8: 32'h698098d8;
        9: 32'h8b44f7af;
        10: 32'hffff5bb1;
        11: 32'h895cd7be;
        12: 32'h6b901122;
        13: 32'hfd987193;
        14: 32'ha679438e;
        15: 32'h49b40821;
        16: 32'hf61e2562;
        17: 32'hc040b340;
        18: 32'h265e5a51;
        19: 32'he9b6c7aa;
        20: 32'hd62f105d;
        21: 32'h02441453;
        22: 32'hd8a1e681;
        23: 32'he7d3fbc8;
        24: 32'h21e1cde6;
        25: 32'hc33707d6;
        26: 32'hf4d50d87;
        27: 32'h455a14ed;
        28: 32'ha9e3e905;
        29: 32'hfcefa3f8;
        30: 32'h676f02d9;
        31: 32'h8d2a4c8a;
        32: 32'hfffa3942;
        33: 32'h8771f681;
        34: 32'h6d9d6122;
        35: 32'hfde5380c;
        36: 32'ha4beea44;
        37: 32'h4bdecfa9;
        38: 32'hf6bb4b60;
        39: 32'hbebfbc70;
        40: 32'h289b7ec6;
        41: 32'heaa127fa;
        42: 32'hd4ef3085;
        43: 32'h04881d05;
        44: 32'hd9d4d039;
        45: 32'he6db99e5;
        46: 32'h1fa27cf8;
        47: 32'hc4ac5665;
        48: 32'hf4292244;
        49: 32'h432aff97;
        50: 32'hab9423a7;
        51: 32'hfc93a039;
        52: 32'h655b59c3;
        53: 32'h8f0ccc92;
        54: 32'hffeff47d;
        55: 32'h85845dd1;
        56: 32'h6fa87e4f;
        57: 32'hfe2ce6e0;
        58: 32'ha3014314;
        59: 32'h4e0811a1;
        60: 32'hf7537e82;
        61: 32'hbd3af235;
        62: 32'h2ad7d2bb;
        63: 32'heb86d391;
        default: 0;
    endcase;
endfunction

function Bit #(32) getShamt(Bit #(32) sel);
    return case (sel)
        0: 7;
        1: 12;
        2: 17;
        3: 22;
        4: 7;
        5: 12;
        6: 17;
        7: 22;
        8: 7;
        9: 12;
        10: 17;
        11: 22;
        12: 7;
        13: 12;
        14: 17;
        15: 22;
        16: 5;
        17: 9;
        18: 14;
        19: 20;
        20: 5;
        21: 9;
        22: 14;
        23: 20;
        24: 5;
        25: 9;
        26: 14;
        27: 20;
        28: 5;
        29: 9;
        30: 14;
        31: 20;
        32: 4;
        33: 11;
        34: 16;
        35: 23;
        36: 4;
        37: 11;
        38: 16;
        39: 23;
        40: 4;
        41: 11;
        42: 16;
        43: 23;
        44: 4;
        45: 11;
        46: 16;
        47: 23;
        48: 6;
        49: 10;
        50: 15;
        51: 21;
        52: 6;
        53: 10;
        54: 15;
        55: 21;
        56: 6;
        57: 10;
        58: 15;
        59: 21;
        60: 6;
        61: 10;
        62: 15;
        63: 21;
    endcase;
endfunction

function Bit #(32) genA = 32'h67452301;
function Bit #(32) genB = 32'hefcdab89;
function Bit #(32) genC = 32'h98badcfe;
function Bit #(32) genD = 32'h10325476;

/* 각 라운드마다 사용되는 함수 정의 */
// round 0
function Bit #(32) fn_F(Bit #(32) x, Bit #(32) y, Bit #(32) z);
    return ((x & y) | (~x & z));
endfunction

// round 1
function Bit #(32) fn_G(Bit #(32) x, Bit #(32) y, Bit #(32) z);
    return ((x & z) | (y & ~z));
endfunction

// round 2
function Bit #(32) fn_H(Bit #(32) x, Bit #(32) y, Bit #(32) z);
    return x ^ y ^ z;
endfunction

// round3
function Bit #(32) fn_I(Bit #(32) x, Bit #(32) y, Bit #(32) z);
    return (y ^ (x | ~z));
endfunction

interface MD5_IFC;
    // request
    (* always_ready *)
    method Action req (Bit #(64) v1);

    // response
    (* always_ready *) method Bool valid;
    (* always_ready *) method WordXL result;
endinterface

(* synthesize *)
module mkMD5 (MD5_IFC);
    Reg #(Bit #(128)) data_i <- mkReg(0);
    Reg #(Bit #(128)) data_o <- mkReg(0);
    Reg #(MD5State) state <- mkReg(MD5_INIT);

    /* input message */
    Reg #(Bit #(512)) message <- mkReg(0);
    Vector #(16, Reg# (Bit #(32))) w <- replicateM(mkReg(0)); // 32비트 단위로 나눔 (+리틀엔디안)

    /* Context Information */
    Reg #(Bit #(64)) ctxSize <- mkReg(0); // 64비트 데이터 길이 (size of input in bytes)
    Vector#(4, Reg #(Bit #(32))) ctxBuffer <- replicateM(mkReg(0)); // current accumulation of hash
    // Vector#(64, Reg #(Bit #(8))) ctxInput;    // Input to be used in the next step
    //Vector#(16, Reg #(Bit #(8))) ctxDigest;   // Result of algorithm
    Reg #(Bit #(128)) digest <- mkReg(0); // result

    /* Used in step */
    Reg #(Bit #(32)) i_step <- mkReg(0);
    Reg #(Bit #(32)) aa <- mkReg(0);
    Reg #(Bit #(32)) bb <- mkReg(0);
    Reg #(Bit #(32)) cc <- mkReg(0);
    Reg #(Bit #(32)) dd <- mkReg(0);

    Reg #(Bool) done <- mkReg(True);

    /* rules */
    (* execution_order = "req, md5Step" *)
    rule md5Step (/*state == MD5_STEP && */i_step < 64 && !done);
        $display("[%d] md5Step", i_step);
        Bit #(32) temp = 32'b0;
        Bit #(32) ee = 32'b0;
        Bit #(32) j = 32'b0;

        if (0 <= i_step && i_step <= 15) begin // stage1
            ee = fn_F(bb, cc, dd);
            j = i_step;
        end
        else if (16 <= i_step && i_step <= 31) begin   // stage2
            ee = fn_G(bb, cc, dd);
            j = ((i_step * 5) + 1) % 16;
        end
        else if (32 <= i_step && i_step <= 47) begin    // stage3
            ee = fn_H(bb, cc, dd);
            j = ((i_step * 3) + 5) % 16;
        end
        else if (48 <= i_step && i_step <= 63) begin    // stage4
            ee = fn_I(bb, cc, dd);
            j = (i_step * 7) % 16;
        end
        temp = dd;
        dd <= cc;
        cc <= bb;
        bb <= bb + rotateLeft((aa + ee + genK(i_step) + w[j]), getShamt(i_step));
        i_step <= i_step + 1;
    endrule

    (* execution_order = "req, md5Step, md5StepDone" *)
    rule md5StepDone (i_step >= 64);
        ctxBuffer[0] <= ctxBuffer[0] + aa;
        ctxBuffer[1] <= ctxBuffer[1] + bb;
        ctxBuffer[2] <= ctxBuffer[2] + cc;
        ctxBuffer[3] <= ctxBuffer[3] + dd;
        digest <= { ctxBuffer[0], ctxBuffer[1], ctxBuffer[2], ctxBuffer[3] };
        done <= True;
        i_step <= 0;
        $display("digest: %x", digest);
    endrule

    // MD5 Interface: request
    // 64비트 고정 길이 메시지가 입력된다. (v1=rs1_val1)
    method Action req (Bit #(64) v1);
        done <= False;
        $display("method req called");
        $display("v1: %x", v1);

        // 버퍼 초기화
        ctxBuffer[0] <= genA;
        ctxBuffer[1] <= genB;
        ctxBuffer[2] <= genC;
        ctxBuffer[3] <= genD;
        aa <= genA;
        bb <= genB;
        cc <= genC;
        dd <= genD;
        //let littleLen = 64'h4000_0000_0000_0000; // 64bit message length
        //let msglen = 64'h40; // 64bit message length
        // padding=512-64-1-64=383
        message <= { v1, 1'b1, 383'b0, /*littleLen*//*msglen*/64'h40 };

        // 메시지를 리틀엔디안 형식으로 저장
        w[0] <= toLE32(message[31:0]);
        w[1] <= toLE32(message[63:32]);
        w[2] <= toLE32(message[95:64]);
        w[3] <= toLE32(message[127:96]);
        w[4] <= toLE32(message[159:128]);
        w[5] <= toLE32(message[191:160]);
        w[6] <= toLE32(message[223:192]);
        w[7] <= toLE32(message[255:224]);

        w[8] <= toLE32(message[287:256]);
        w[9] <= toLE32(message[319:288]);
        w[10] <= toLE32(message[351:320]);
        w[11] <= toLE32(message[383:352]);
        w[12] <= toLE32(message[415:384]);
        w[13] <= toLE32(message[447:416]);
        w[14] <= toLE32(message[479:448]);
        w[15] <= toLE32(message[511:480]);
        
        i_step <= 0;

        $display("ctxBuffer[0]: %x", ctxBuffer[0]);
        $display("ctxBuffer[1]: %x", ctxBuffer[1]);
        $display("ctxBuffer[2]: %x", ctxBuffer[2]);
        $display("ctxBuffer[3]: %x", ctxBuffer[3]);
        $display("message: %x", message);
    endmethod

    // MD5 Interface: response
    method Bool valid;
        return done;
    endmethod

    method WordXL result; // if (done);
        return digest[63:0];
    endmethod
endmodule

endpackage