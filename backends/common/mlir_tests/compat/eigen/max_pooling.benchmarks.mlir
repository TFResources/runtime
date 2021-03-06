// Copyright 2020 The TensorFlow Runtime Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// RUN: tfrt_translate -mlir-to-bef %s | bef_executor | FileCheck %s --dump-input=fail

// CHECK-LABEL: --- Running 'BM_MaxPool2D_in_8x32x32x128_p_3x3_s_2x2'
func @BM_MaxPool2D_in_8x32x32x128_p_3x3_s_2x2() {
  %ch0 = hex.new.chain

  %zero = hex.constant.f32 0.0
  %one = hex.constant.f32 1.0

  // in: [8, 32, 32, 128].
  %in = "dht.create_uninitialized_tensor.f32.4"()
    { shape = [8 : i64, 32 : i64, 32 : i64, 128 : i64] }
    : () -> !t.tensor
  %ch1 = dht.fill_tensor_with_constant.f32 %in, %ch0 1.0 : f32

  // out: [8, 15, 15, 128].
  %out = "dht.create_uninitialized_tensor.f32.4"()
    { shape = [8 : i64, 15 : i64, 15 : i64, 128 : i64] }
    : () -> !t.tensor

  tfrt_test.benchmark "BM_MaxPool2D_in_8x32x32x128_p_3x3_s_2x2"(
      %in   : !t.tensor,
      %out  : !t.tensor,
      %ch1  : !hex.chain
  )
  duration_secs = 5, max_count = 1000, num_warmup_runs = 10
  {
      %ch_out = "eigen.max_pooling_2d.f32"(%in, %out, %ch1)
       { padding = "valid",  pool_size = [3 : i64, 3 : i64],
         strides = [2 : i64, 2 : i64]
       }
       : (!t.tensor, !t.tensor, !hex.chain) -> !hex.chain

      hex.return %ch_out : !hex.chain
  }

  hex.return
}
