---
Title: .NET Core 3.1と.NET 5のfor-loopの速度比較
Published: 11/19/2020
Updated: 11/19/2020
Tags: [dotnet, csharp]
---

## はじめに

.NET 5でいろいろなパフォーマンスが向上したらしいので、1次元配列、2次元配列、2次元ジャグ配列、3次元配列、3次元配列のfor-loopのベンチマークを取ってみた。

## 環境

- OS: Windows 10
- CPU: AMD Ryzen 5 3600
- SDK: .NET 5.0
- BenchmarkDotnet: 0.12.1

### 計測対象

- Runtimes
  - .NET Core 3.1.9
  - .NET 5
- Targets
  - 1次元配列 (1e6)
  - 2次元配列 (1e3 * 1e3)
  - 2次元ジャグ配列 (1e3 * 1e3)
  - 3次元配列 (1e2 *1e2* 1e2)
  - 3次元ジャグ配列 (1e2 *1e2* 1e2)

### 操作

全ての要素に値を代入

### スクリプト

```csharp
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Jobs;

namespace BenchmarkSharp
{
    [SimpleJob(RuntimeMoniker.NetCoreApp31, baseline: true)]
    [SimpleJob(RuntimeMoniker.NetCoreApp50)]
    [MemoryDiagnoser]
    public class ForLoopBenchmark
    {
        private const int Size1 = (int) 1e6;
        private const int Size2 = (int) 1e3;
        private const int Size3 = (int) 1e2;
        private int[] _dim1;
        private int[,] _dim2;
        private int[][] _dim2Jagged;
        private int[,,] _dim3;
        private int[][][] _dim3Jagged;

        [GlobalSetup]
        public void Setup()
        {
            _dim1 = new int[Size1];
            _dim2 = new int[Size2, Size2];
            _dim3 = new int[Size3, Size3, Size3];
            _dim2Jagged = new int[Size2][];
            for (var i = 0; i < _dim2Jagged.Length; i++) _dim2Jagged[i] = new int[Size2];
            _dim3Jagged = new int[Size3][][];
            for (var i = 0; i < _dim3Jagged.Length; i++)
            {
                _dim3Jagged[i] = new int[Size3][];
                for (var j = 0; j < _dim3Jagged[i].Length; j++)
                {
                    _dim3Jagged[i][j] = new int[Size2];
                }
            }
        }

        [Benchmark]
        public void Dim1()
        {
            for (var i = 0; i < _dim1.Length; i++) _dim1[i] = i;
        }

        [Benchmark]
        public void Dim2()
        {
            for (var i = 0; i < _dim2.GetLength(0); i++)
            for (var j = 0; j < _dim2.GetLength(1); j++)
                _dim2[i, j] = j;
        }

        [Benchmark]
        public void Dim2Jagged()
        {
            for (var i = 0; i < _dim2Jagged.Length; i++)
            for (var j = 0; j < _dim2Jagged[i].Length; j++)
                _dim2Jagged[i][j] = j;
        }

        [Benchmark]
        public void Dim3()
        {
            for (var i = 0; i < _dim3.GetLength(0); i++)
            for (var j = 0; j < _dim3.GetLength(1); j++)
            for (var k = 0; k < _dim3.GetLength(2); k++)
                _dim3[i, j, k] = k;
        }

        [Benchmark]
        public void Dim3Jagged()
        {
            for (var i = 0; i < _dim3Jagged.Length; i++)
            for (var j = 0; j < _dim3Jagged[i].Length; j++)
            for (var k = 0; k < _dim3Jagged[i][j].Length; k++)
                _dim3Jagged[i][j][k] = k;
        }
    }
}
```

## 結果

|     Method |           Job |       Runtime |        Mean |       Error |      StdDev |      Median | Ratio | RatioSD | Gen 0 | Gen 1 | Gen 2 | Allocated |
|----------- |-------------- |-------------- |------------:|------------:|------------:|------------:|------:|--------:|------:|------:|------:|----------:|
|       Dim1 | .NET Core 3.1 | .NET Core 3.1 |    565.1 μs |     3.35 μs |     3.14 μs |    566.0 μs |  1.00 |    0.00 |     - |     - |     - |       1 B |
|       Dim1 | .NET Core 5.0 | .NET Core 5.0 |    525.8 μs |    10.49 μs |    24.53 μs |    508.9 μs |  0.92 |    0.03 |     - |     - |     - |         - |
|            |               |               |             |             |             |             |       |         |       |       |       |           |
|       Dim2 | .NET Core 3.1 | .NET Core 3.1 |  5,366.7 μs |    47.74 μs |    44.65 μs |  5,357.6 μs |  1.00 |    0.00 |     - |     - |     - |     111 B |
|       Dim2 | .NET Core 5.0 | .NET Core 5.0 |  3,544.6 μs |   230.75 μs |   680.38 μs |  3,060.7 μs |  0.64 |    0.13 |     - |     - |     - |         - |
|            |               |               |             |             |             |             |       |         |       |       |       |           |
| Dim2Jagged | .NET Core 3.1 | .NET Core 3.1 |  1,514.8 μs |    29.53 μs |    35.16 μs |  1,522.0 μs |  1.00 |    0.00 |     - |     - |     - |         - |
| Dim2Jagged | .NET Core 5.0 | .NET Core 5.0 |  2,003.3 μs |     8.14 μs |     7.22 μs |  2,001.9 μs |  1.33 |    0.03 |     - |     - |     - |         - |
|            |               |               |             |             |             |             |       |         |       |       |       |           |
|       Dim3 | .NET Core 3.1 | .NET Core 3.1 |  5,209.7 μs |    45.24 μs |    40.10 μs |  5,201.5 μs |  1.00 |    0.00 |     - |     - |     - |      10 B |
|       Dim3 | .NET Core 5.0 | .NET Core 5.0 |  4,525.7 μs |   246.02 μs |   725.38 μs |  4,114.5 μs |  0.90 |    0.15 |     - |     - |     - |         - |
|            |               |               |             |             |             |             |       |         |       |       |       |           |
| Dim3Jagged | .NET Core 3.1 | .NET Core 3.1 | 18,504.2 μs |   466.86 μs | 1,376.55 μs | 18,885.7 μs |  1.00 |    0.00 |     - |     - |     - |         - |
| Dim3Jagged | .NET Core 5.0 | .NET Core 5.0 | 17,920.7 μs | 1,043.53 μs | 3,076.86 μs | 19,831.3 μs |  0.98 |    0.20 |     - |     - |     - |         - |

## まとめ

.NET 5.0は .NET Core 3.1に比べて

- 1次元配列 -> 10%程度高速
- 2次元配列 -> 35%程度高速
- 2次元ジャグ配列 -> 35%程度低速
- 3次元配列 -> 10%程度高速
- 3次元ジャグ配列 -> ほぼ一緒

.NET 5.0において多次元配列と多次元ジャグ配列の各次元のサイズが同じ大きさであれば

- 2次元 -> ジャグ配列のほうが40%程度高速
- 3次元 -> 配列のほうが75%程度高速
