Title: dotnet newのカスタムテンプレート
Published: 11/29/2020
Updated: 12/08/2020
Tags: [.NET] 
---

# はじめに

[競プロ用のプロジェクトテンプレート](https://github.com/AconCavy/CompetitiveProgrammingTemplateCSharp)を整備したので，`dotnet new`のカスタムテンプレート作成の備忘録です．

# dotnet new のカスタムテンプレートとは

公式の情報は[こちら](https://docs.microsoft.com/ja-jp/dotnet/core/tools/custom-templates)

.NETのプロジェクトを作成する際，`dotnet`コマンドを利用してプロジェクトを生成します．
例えば，コンソールアプリケーションを作成する場合，

```sh
dotnet new console -n Sample
```

のようなコマンドを実行することで，`Sample`という名称のプロジェクトが作成されます．
これは，`dotnet new`コマンドで，`console`というデフォルトテンプレートを使ってプロジェクトを生成するという意味になります．

この`dotnet new`コマンドに，プロジェクトやスクリプトをカスタムテンプレートとして登録しておくことで，プロジェクトやファイルの作成を使いまわすことができます．

既定のテンプレートとして，`dotnet new`コマンドに`-l|--list`オプションをつけて実行すると，現在インストールされている`dotnet new`コマンドで生成できるテンプレートを確認することができます．

```sh
dotnet new -l
```

# 作ってみる

テンプレートの基本として，テンプレート化したいプロジェクトのディレクトリ下に，`.template.config`のディレクトリを作成し，さらにその下に，`template.json`を作成します．
そして，`template.json`にプロパティを設定し，`dotnet new`コマンドを使ってインストールすることで，テンプレートを使うことができるようになります．

```sh
dotnet new -i path-to-template
```

競技プロ用のプロジェクトテンプレートでは，次の3つをテンプレートとして準備します．

- プロジェクト
- 解答用のクラス
- テスト用のクラス

## プロジェクトのテンプレート

プロジェクトでは，解答用のクラスとテスト用クラスを配置するための骨組みとしてのプロジェクトを生成するようにします．

```
Template.Project/
    |
    |- Tasks/
    |    |
    |    |- Tasks.csproj
    |
    |- Tests/
    |    |
    |    |- Tester.cs
    |    |- Tests.csproj
    |
    |- Template.Project.sln
```

このプロジェクトをベースとして，`Project/`下に`.template.config/`ディレクトリを作成し，その下に`template.json`を作成します．

```
Template.Project/
    |
    |- .template.config
    |    |
    |    |- template.json
    ...
```

`template.json`では，次のメンバを記述します．

| メンバ | 説明 |
|:-:|:--|
| `$schema` | `template.json`のスキーマ |
| `author` | テンプレートの作成者 |
| `classfication` | テンプレートの種類 |
| `tags` | テンプレートのタグ |
| `identity` | テンプレートの識別子 |
| `name` | テンプレートの名前 |
| `shortName` | `dotnet new` で指定する際の名前 (例: `dotnet new cpproj`) |
| `sourceName` | テンプレート使用時に置き換える文字列  (`dotnet new`コマンドに，`-n|--name`オプションで名前を指定することで，指定された文字列を全てその名前に置換することができます) |
| `preferNameDirectory` | 出力先ディレクトリがない場合テンプレートのディレクトリを作成するか (既定値: false) |

例えば，上記のプロジェクトでは次のような`json`を記述します．

```json
{
    "$schema": "http://json.schemastore.org/template",
    "author": "AconCavy",
    "classifications": [
        "C#",
        "Console"
    ],
    "tags": {
        "language": "C#",
        "type": "project"
    },
    "name": "Template Project",
    "identity": "AconCavy.Template.Project",
    "shortName": "cpproj",
    "sourceName": "Template.Project",
    "preferNameDirectory": true
}
```

`sourceName`に設定した文字列は，テンプレート以下のすべての対象の文字列が置換されるため，`dotnet new cpproj -n Sample`を実行した場合，`Template.Project/`ディレクトリ，`Template.Project.sln`が`Sample/`ディレクトリ，`Sample.sln`に置換されて生成されます．ファイル内の文字列も置換されるため注意が必要です．

この状態で，`dotnet new -i path-to-template`コマンドでインストールし，`dotnet new cpproj -n Sample`を実行することで，上記のプロジェクトテンプレートをもとに以下のようなプロジェクトが生成されます．

```
Sample/
    |
    |- Tasks/
    |    |
    |    |- Tasks.csproj
    |
    |- Tests/
    |    |
    |    |- Tester.cs
    |    |- Tests.csproj
    |
    |- Sample.sln
```

### コマンドの追加オプション

また，`Task.csproj`と`Tests.csproj`のターゲットフレームワークをテンプレート生成時に指定できるようにするため，`dotnet new cpproj`コマンドにオプションを追加します．

まず，`.template.config`下に`dotnetcli.host.json`を追加します．
`symbolInfo`メンバに，`longName`のオプションに`framework`を，`shortName`に`f`をもった`Framework`というメンバを追加します．
追加することで，`dotnet new cpproj`にオプションとして，`-f|--framework`のオプションを付与することができるようになります．

```json
{
    "$schema": "http://json.schemastore.org/dotnetcli.host",
    "symbolInfo": {
        "Framework": {
            "longName": "framework",
            "shortName": "f"
        }
    }
}
```

次に`template.json`に`symbols`というメンバを追加し，ここに先ほど定義した`Framework`メンバを追加します．
ここではオプションの振る舞いを定義します．

今回はターゲットフレームワークを`.NET 5`と`.NET Core 3.1`を選択肢として定義します．
`datatype`を`choice`にして，`choices`に選択肢を定義します．
`csproj`の`TargetFramework`に指定する文字列として，`.NET 5`の場合は`net5.0`，`.NET Core 3.1`の場合は`netcoreapp3.1`を`choice`に設定します．
`replaces`に置換する文字列を，`defaultValue`にオプションを指定しない場合の文字列を設定します．

```json
{
    ...
    "symbols": {
        "Framework": {
            "type": "parameter",
            "description": "The target framework for the project.",
            "datatype": "choice",
            "choices": [
                {
                    "choice": "net5.0",
                    "description": "Target net5.0"
                },
                {
                    "choice": "netcoreapp3.1",
                    "description": "Target netcoreapp3.1"
                }
            ],
            "replaces": "netcoreapp3.1",
            "defaultValue": "netcoreapp3.1"
        }
    },
    ...
}
```

そして，`Tasks.csproj`と`Tests.csproj`の`TargetFramework`に`replaces`で設定した文字列を設定します．

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    ...
    <TargetFramework>netcoreapp3.1</TargetFramework>
    ...
  </PropertyGroup>
  ...

</Project>

```

この状態で，`dotnet new cpproj -n Sample -f net5.0`を実行することで，`TargetFramework`に`net5.0`が設定されたプロジェクトを生成することができます．


## 解答用のクラスとテスト用のクラスのテンプレート

単一のファイルのみ生成するように，テンプレートを構築します．

```
Template.Solver/
    |
    |- .template.config/
    |    |
    |    |- template.json
    |
    |- Template.Solver.cs

Template.Tests/
    |
    |- .template.config/
    |    |
    |    |- template.json
    |
    |- Template.TestsTests.cs
```

プロジェクトのテンプレートの作り方と同様に，`template.json`を記述しますが，単一ファイルのみ生成させるため，`preferNameDirectory`を削除，または`false`にします．

解答用の`sourceName`を`Template.Solver`に，テスト用の`sourceName`を`Template.Tests`にすることで，`dotnet new`コマンドの`-n|--name`オプションに`Sample`を指定すると，それぞれ`Sample.cs`と`SampleTests.cs`が生成されます．

## プロジェクトのパッケージ化

テンプレートが3つ用意できましたが，テンプレートをインストールする際にはそれぞれ個別にインストールが必要となります．
そのため，3つのテンプレートまとめて，1つの`nuget`パッケージを生成します．
3つのディレクトリを一つのディレクトリにまとめ，そのディレクトリと同じ階層に`csproj`ファイルを生成します．

```
CPTemplate/
    |
    |- content/
    |    |
    |    |- Template.Project/
    |    |- Template.Solver/
    |    |- Template.Tests/
    |
    |- CPTemplate.csproj
```

ディレクトリを整理したら，`CPTemplate.csproj`を編集し，ビルド情報を定義します．

| メンバ | 説明 |
|:-:|:--|
| `PackageType` | `nuget`パッケージタイプ |
| `PackageVersion` | パッケージのバージョン |
| `PackageId` | パッケージの識別子 |
| `Title` | パッケージの名称 |
| `Authors` | パッケージの作成者 |
| `Description` | パッケージの説明 |
| `PackageTags` | パッケージのタグ |
| `TargetFramework` | パッケージをビルドするためのターゲットフレームワーク |
| `PackageProjectUrl` | プロジェクトURL |
| `IncludeBuildOutput` | ビルド時に生成されるファイルをパッケージに含めるか |
| `ContentTargetFolders` | パッケージ化するプロジェクトのルートが`content`か`contentFiles`以外の場合は設定する |
| `Content` | パッケージに含めるファイルや除くファイルを設定する |


```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <PackageType>Template</PackageType>
    <PackageVersion>1.0</PackageVersion>
    <PackageId>AconCavy.Templates</PackageId>
    <Title>Templates</Title>
    <Authors>AconCavy</Authors>
    <Description>sample template.</Description>
    <PackageTags>dotnet-new;templates;competitive-programming</PackageTags>
    <TargetFramework>netcoreapp3.1</TargetFramework>
    <PackageProjectUrl>https://github.com/AconCavy/CompetitiveProgrammingTemplateCSharp</PackageProjectUrl>

    <IncludeBuildOutput>false</IncludeBuildOutput>
    <ContentTargetFolders>content</ContentTargetFolders>
  </PropertyGroup>

  <ItemGroup>
    <Content Include="content/**/*" Exclude="content/**/bin/**;content/**/obj/**" />
    <Compile Remove="**/*" />
  </ItemGroup>

</Project>
```

また，それぞれのテンプレートの`template.json`に`groupIdentity`を追加します．

```json
// Project
"groupIdentity": "AconCavy.Templates.Project"

// Solver
"groupIdentity": "AconCavy.Templates.Solver"

// Tests
"groupIdentity": "AconCavy.Templates.Tests"
```

`dotnet pack`コマンドを実行することで`nuget`パッケージを生成することができます．

```sh
dotnet pack
```

実行後，`bin/Debug/`下に`{PackageId}.{PackageVersion}.nupkg`が生成されます．

```
CPTemplate/
    |
    |- bin/
    |    |
    |    |- Debug/
    |    |    |
    |    |    |- AconCavy.Templates.1.0.0.nupkg
    ...
```

この`nupkg`を`dotnet new`コマンドでインストールすることで，3つのテンプレートを1回でインストールすることができます．

```sh
dotnet new -i ./bin/Debug/AconCavy.Templates.1.0.0.nupkg
```

# まとめ

`dotnet new`のカスタムテンプレートの作り方と，テンプレートのパッケージ化の手順をまとめました．

- テンプレートのルートに`.template.config`ディレクトリを作成し，内に`template.json`を作成する．
- テンプレートが複数ある場合は1つのディレクトリにまとめ，`dotnet pack`コマンドでパッケージ化する．
