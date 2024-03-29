---
Title: PH__Title
Published: PH__Published
Updated: PH__Updated
Tags: [atcoder, csharp]
---

## はじめに

PH__ContestFullNameの復習記事です。

記事における`Scanner`クラスは、自作の入力クラスです。

<details>
<summary>Scannerクラス</summary>

```csharp
public static class Scanner
{
    public static T Scan<T>() where T : IConvertible => Convert<T>(ScanStringArray()[0]);
    public static (T1, T2) Scan<T1, T2>() where T1 : IConvertible where T2 : IConvertible
    {
        var input = ScanStringArray();
        return (Convert<T1>(input[0]), Convert<T2>(input[1]));
    }
    public static (T1, T2, T3) Scan<T1, T2, T3>() where T1 : IConvertible where T2 : IConvertible where T3 : IConvertible
    {
        var input = ScanStringArray();
        return (Convert<T1>(input[0]), Convert<T2>(input[1]), Convert<T3>(input[2]));
    }
    public static (T1, T2, T3, T4) Scan<T1, T2, T3, T4>() where T1 : IConvertible where T2 : IConvertible where T3 : IConvertible where T4 : IConvertible
    {
        var input = ScanStringArray();
        return (Convert<T1>(input[0]), Convert<T2>(input[1]), Convert<T3>(input[2]), Convert<T4>(input[3]));
    }
    public static (T1, T2, T3, T4, T5) Scan<T1, T2, T3, T4, T5>() where T1 : IConvertible where T2 : IConvertible where T3 : IConvertible where T4 : IConvertible where T5 : IConvertible
    {
        var input = ScanStringArray();
        return (Convert<T1>(input[0]), Convert<T2>(input[1]), Convert<T3>(input[2]), Convert<T4>(input[3]), Convert<T5>(input[4]));
    }
    public static (T1, T2, T3, T4, T5, T6) Scan<T1, T2, T3, T4, T5, T6>() where T1 : IConvertible where T2 : IConvertible where T3 : IConvertible where T4 : IConvertible where T5 : IConvertible where T6 : IConvertible
    {
        var input = ScanStringArray();
        return (Convert<T1>(input[0]), Convert<T2>(input[1]), Convert<T3>(input[2]), Convert<T4>(input[3]), Convert<T5>(input[4]), Convert<T6>(input[5]));
    }
    public static IEnumerable<T> ScanEnumerable<T>() where T : IConvertible => ScanStringArray().Select(Convert<T>);
    private static string[] ScanStringArray()
    {
        var line = Console.ReadLine()?.Trim() ?? string.Empty;
        return string.IsNullOrEmpty(line) ? Array.Empty<string>() : line.Split(' ');
    }
    private static T Convert<T>(string value) where T : IConvertible => (T)System.Convert.ChangeType(value, typeof(T));
}
```

</details>

## コンテスト

<https://atcoder.jp/contests/PH__ContestName>

### [問題A](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_a)

[コンテスト提出]()

<details>
<summary>例</summary>

```csharp
```

</details>

### [問題B](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_b)

[コンテスト提出]()

<details>
<summary>例</summary>

```csharp
```

</details>

### [問題C](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_c)

[コンテスト提出]()

<details>
<summary>例</summary>

```csharp
```

</details>

### [問題D](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_d)

[コンテスト提出]()  
[復習提出]()

<details>
<summary>例</summary>

```csharp
```

</details>

### [問題E](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_e)

[コンテスト提出]()  
[復習提出]()

<details>
<summary>例</summary>

```csharp
```

</details>

### [問題F](https://atcoder.jp/contests/PH__ContestName/tasks/PH__ContestName_f)

[コンテスト提出]()  
[復習提出]()

<details>
<summary>例</summary>

```csharp
```

</details>
