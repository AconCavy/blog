Title: MagicOnionに入門した
Published: 01/03/2021
Updated: 01/03/2021
Tags: [Unity, MagicOnion, MessagePack] 

--

# はじめに

友人がC#のgRPCライブラリの`MagicOnion`の導入に苦戦してたので，手伝いながら使ってみたときにつまったところを纏めたものです．

リポジトリは[こちら](https://github.com/AconCavy/MagicOnionSample)

# MagicOnion

[MagicOnion](https://github.com/Cysharp/MagicOnion)は，共通のインターフェースを介してクライアントとサーバーで手続きを呼び合う技術の[gRPC](https://github.com/grpc/grpc)をC#用に最適化した，リアルタイム通信ライブラリです．

ASP.NET CoreにもgRPCのテンプレートは存在しますが，そちらは`proto`ファイルを作成し，そのファイルにインターフェースを定義を行います．一方MagicOnionの場合は，C#の`interface`を定義すればめんどくさいことはMagicOnion側でいろいろやってくれるため，クライアントとサーバーでどちらもC#を利用する場合には一つのソースを使いまわすことができたりと嬉しいことが多いです．そのため，クライアントはUnity，サーバーはASP.NET Coreを使うモバイルゲームなどのプロジェクトでよく使われるそうです．

# 環境

- Unity 2019.4.17f1
- [MagicOnion 4.0.4](https://github.com/Cysharp/MagicOnion/releases/tag/4.0.4)
- [MessagePack for C# 2.2.85](https://github.com/neuecc/MessagePack-CSharp/releases/tag/v2.2.85)
- gRPC ([grpc_unity_package.2.35.0-dev202012021242](https://packages.grpc.io/archive/2020/12/d7b70c3ea25c48ffdae7b8bd3c757594d4fff4b6-2be69c7e-9b25-4273-a7d4-3840da2d6723/csharp/grpc_unity_package.2.35.0-dev202012021242.zip))

# 作ってみる1

MagicOnionを使うにあたって，ASP.NET Coreでのサーバー，Unityでのクライアント，共有Apiの3つのプロジェクトを構成します．

```
MagicOnionSample/
  |- MagicOnionSample.Server/
  |- MagicOnionSample.Shared/
  |- MagicOnionSample.Unity/
  |
  |- MagicOnionSample.sln
```

`MagicOnionSample.Server`はASP.NET CoreのgRPCテンプレートで作成しました．
`MagicOnionSample.Unity`にはUnityプロジェクトを作成します．
`MagicOnionSample.sln`には`MagicOnionSample.Server`と`MagicOnionSample.Shared`を追加します．

## クライアント側の準備

プロジェクトを作成したら，はじめに`Project Settings`を以下に変更します．

|Item|Value|
|:-:|:-:|
| `Scripting Backend` | `Mono` |
| `Api Compatibility Level` | `.NET 4.x` |
| `Allow unsafe code` | `True` |

次に，MagicOnionとMessagePackの`unitypackage`をプロジェクトにインポートします．
また，gRPCのパッケージから，`Google.Protobuf`，`Grpc.Core`， `Grpc.Core.Api`の3つのフォルダを`Assets/Plugins/`にインポートします．

MagicOnionとMessagePackのバージョンによってはUnityのコンパイルエラーは発生しませんが，MagicOnion 4.0.4とMessagePack 2.2.85の場合はMagicOnion側でコンパイルエラーが発生してしまいます．MessagePack 2.2.85からMessagePackの属性が含まれている名前空間が`MessagePack`から`MessagePack.Annotations`に変更されているようなので，`Assets/Scripts/MagicOnion.Client/MagicOnion.Client.asmdef`の `AssemblyDefinition References`に`MessagePack.Annotations`の参照を追加することでコンパイルエラーを解消できます．

## サーバー側の準備

ASP.NET CoreのgRPCテンプレートで作成した場合，以下のような構成でプロジェクトが作成されます．

```
MagicOnionSample
  |-MagicOnionSample.Server
      |- Properties/
      |    |- launchSettings.json
      |- Protos/
      |    |- greet.proto
      |- Services/
      |    |- GreeterService.cs
      |- appsettings.json
      |- appsettings.development.json
      |- Program.cs
      |- Startup.cs
```

この状態から，`Protos`ディレクトリと，`GreeterService.cs`を削除します．
次に`Startup.cs`の`GenericHost`の構成にMagicOnionを追加します．

```csharp
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

namespace MagicOnionSample.Server
{
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddGrpc();
            services.AddMagicOnion(); // Here
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseRouting();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapMagicOnionService(); // Here
                endpoints.MapGet("/",
                    async context =>
                    {
                        await context.Response.WriteAsync(
                            "Communication with gRPC endpoints must be made through a gRPC client. To learn how to create a client, visit: https://go.microsoft.com/fwlink/?linkid=2086909");
                    });
            });
        }
    }
}
```

また，今回は`localhost`で通信を行うので，`appsettings.development.json`に以下の設定を追加します．

```json
...
"Kestrel": {
    "Endpoints": {
      "Grpc": {
        "Url": "http://localhost:5000",
        "Protocols": "Http2"
      },
      "Https": {
        "Url": "https://localhost:5001",
        "Protocols": "Http1AndHttp2"
      },
      "Http": {
        "Url": "http://localhost:5002",
        "Protocols": "Http1"
      }
    }
  }
...
```

また，`Program.cs`の`CreateHostBuilder`に`Kestrel`とHttp2を使うための設定を追加します．

```csharp
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Hosting;

namespace MagicOnionSample.Server
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args)
        {
            return Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder => webBuilder
                    .UseKestrel(options => options.ConfigureEndpointDefaults(endpointOptions =>
                        endpointOptions.Protocols = HttpProtocols.Http2))
                    .UseStartup<Startup>());
        }
    }
}
```

Httpsで通信を行う場合は，[こちら](https://docs.microsoft.com/ja-jp/aspnet/core/security/enforcing-ssl?view=aspnetcore-5.0&tabs=visual-studio)を参照してください．

## 共有Apiの定義

Unityに戻り，MagicOnionで使用する`interface`やモデルクラス類を作成します．
今回は`Assets/MagicOnionSample/Scripts/Shared/`に共有Apiを構成します．

`Shared`ディレクトリに`ISampleService.cs`を作成し,`string`の値を渡すと挨拶の`string`を返す`interface`を定義します．また，この`interface`には`IService<T>`もあわせて定義します．

```csharp
using MagicOnion;

namespace MagicOnionSample.Shared
{
    public interface ISampleService : IService<ISampleService>
    {
        UnaryResult<string> GreetAsync(string name);
    }
}
```

## クライアント側の実装

`Shared`ディレクトリでは，クライアントとサーバーで共有できるクラスやインターフェースのみを持たせるために，`Shared`ディレクトリとは別に，`Assets/MagicOnionSample/Scripts/Unity/`を作成し，名前空間と実装を分離します．

`Unity`ディレクトリに`SampleEntryPoint.cs`を作成し，サーバーにローカルホストでアクセスする実装をします．

`MagicOnionClient`から`ISampleService`のエンドポイントに対して，上記で定義した`GreetAsync`を`interface`経由で呼び，結果を`Debug.Log`に表示させます．
`interface`経由で呼ぶことで，クライアント側は実装を気にする必要がありません．

```csharp
using System.Threading.Tasks;
using Grpc.Core;
using MagicOnion.Client;
using MagicOnionSample.Shared;
using UnityEngine;

namespace MagicOnionSample.Unity
{
    public class SampleEntryPoint : MonoBehaviour
    {
        public string host = "localhost";
        public int port = 5000;

        public string user = "Foo";
        public string room = "Bar";

        private Channel _channel;

        private async Task Start()
        {
            _channel = new Channel(host, port, ChannelCredentials.Insecure);

            var client = MagicOnionClient.Create<ISampleService>(_channel);
            var greet = await client.GreetAsync(user);
            Debug.Log(greet);
        }

        private async Task OnDestroy()
        {
            await _channel.ShutdownAsync();
        }
    }
}
```

作成後，UnityのHierarchyに適当なGameObjectを作成し，`SampleEntryPoint`を付与します．

## サーバー側における共有Api

Unityがコンパイルできるスクリプトは`Assets/`以下にあるものに限るため，サーバー側で共有Api用のプロジェクトを作成すると不整合がおきてしまうかもしれません．そのため，`MagicOnionSample.Shared`のプロジェクトでは，中身を実際には持たずに，上記で作成したUnityプロジェクト内の`Assets/MagicOnionSample/Scripts/Shared`ディレクトリにあるスクリプトを参照することでサーバー側でも共有Apiとして使えるようにします．

そのため，`MagicOnionSample.Shared`のディレクトリ構成は以下のようになります．

```
MagicOnionSample
  |-MagicOnionSample.Shared
      |-MagicOnionSample.Shared.csproj
```

nugetから`MagicOnion`，`MagicOnion.Abstractions`，`MessagePack`，`MessagePack.UnityShims`をインストールします．
`MessagePack.UnityShims`をインストールすることで，UnityEngineのApiを利用することができるため，`Vector3`や`Quatarnion`などを使う場合はインストールします．

`<Compile Include="path/to/file"/>`を定義することで，指定したパスのファイルをコンパイルに含めることができます．

`csproj`は以下のようになります．

```xml
<Project Sdk="Microsoft.NET.Sdk">

    <PropertyGroup>
        <TargetFramework>netcoreapp3.1</TargetFramework>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="MagicOnion" Version="4.0.4" />
        <PackageReference Include="MagicOnion.Abstractions" Version="4.0.4" />
        <PackageReference Include="MessagePack" Version="2.2.85" />
        <PackageReference Include="MessagePack.UnityShims" Version="2.2.85" />
    </ItemGroup>

    <ItemGroup>
        <Compile Include="../MagicOnionSample.Unity/Assets/MagicOnionSample/Scripts/Shared/**/*.cs" />
    </ItemGroup>

</Project>
```
## サーバー側の実装

上記で準備した共有Apiのプロジェクトをサーバー側のプロジェクトで参照することで，Unity上で定義した`ISampleService`を利用することができるようになります．
`SampleService.cs`を作成し，`ISampleService`の実装を行います．
簡単な文字列を返すように実装しました．

```csharp
using System;
using MagicOnion;
using MagicOnion.Server;
using MagicOnionSample.Shared;

namespace MagicOnionSample.Server.Services
{
    public class SampleService : ServiceBase<ISampleService>, ISampleService
    {
        public async UnaryResult<string> GreetAsync(string name)
        {
            await Console.Out.WriteLineAsync(name);
            return $"Welcome {name}!";
        }
    }
}
```

## 動作確認

`dotnet run`コマンド等でサーバーを起動し，`SampleEntryPoint`が適当なGameObjectに付与されているのを確認した後にUnityを実行し，UnityのConsoleに`Welcome Foo!`と表示されたら成功です．
以上で，サーバーとクライアントの1対1のApiコールができました．

# 作ってみる2

前の項では，サーバーとクライアントの1対1のApiコールを実装しました．次に，サーバーとクライアントの1対多のApiコールを実装します．
マルチプレイでプレイヤーの座標をリアルタイムで同期させるといったことが用途としてあげられます．

今回は，プレイヤーが部屋に参加したかどうかを知らせるApiを実装します．

## 共有Apiの定義

初めに，`Player`を一つのモデルとして管理するために，`Shared`ディレクトリに`Player.cs`を作成します．
`MessagePackObject`の属性をクラスや構造体に付与することで，MessagePackがシリアライズできるようになり，`Key`によってそれぞれのプロパティを管理します．

```csharp
using MessagePack;

namespace MagicOnionSample.Shared
{
    [MessagePackObject]
    public class Player
    {
        [Key(0)] public string Name { get; set; }
        [Key(1)] public string Room { get; set; }
    }
}
```

次に，`Shared`ディレクトリに`ISampleHubReceiver.cs`を作成します．
`Player`が部屋に参加したことを知らせるコールバークとしての`interface`を定義します．

```csharp
namespace MagicOnionSample.Shared
{
    public interface ISampleHubReceiver
    {
        void OnJoin(Player player);
    }
}
```

また，`Shared`ディレクトリに`ISampleHub.cs`を作成します．
`name`と`room`を渡すことで，部屋に参加する`interface`を定義します．この`interface`には`IStreamingHub<T, U>`もあわせて定義します．

`ISampleService`と同じようにApiコール用の`interface`です．

```csharp
using System.Threading.Tasks;
using MagicOnion;

namespace MagicOnionSample.Shared
{
    public interface ISampleHub : IStreamingHub<ISampleHub, ISampleHubReceiver>
    {
        Task JoinAsync(string name, string room);
    }
}
```

これらのApiコールのの流れとして，`ISampleHub`の`JoinAsync`を呼ぶことで，サーバーに名前と部屋名を渡し，サーバー側の処理が完了すると`ISampleHubReceiver`の`OnJoin`がコールバックとして呼ばれる形になります．

## クライアント側の実装

クライアント側では，`ISampleHubReceiver`を実装した`SampleHubReceiver`を作成します．
`Unity`ディレクトリに`SampleHubReceiver.cs`を作成し，コールバックの内容を実装します．
`Player`が参加したら`Player`の`Name`と`Room`がUnityのConsoleに表示されます．

```csharp
using MagicOnionSample.Shared;
using UnityEngine;

namespace MagicOnionSample.Unity
{
    public class SampleHubReceiver : ISampleHubReceiver
    {
        public void OnJoin(Player player)
        {
            Debug.Log($"{player.Name}, {player.Room}");
        }
    }
}
```

上記で作成した`SampleEntryPoint.cs`を更新します．

`Channel`と`ISampleReceiver`のインスタンスを`StreamingHubClient.Connect`に渡すことで，`ISampleHub`を実装したインスタンスを得ることができます．このインスタンスはサーバー側で実装されるので，クライアント側は気にする必要がありません．
`ISampleHub`のインスタンスを使って`JoinAsync`を呼ぶことで，サーバー側に`name`と`room`を渡すことができ，コールバックとして`SampleHubReceiver`の`OnJoin`に`Player`のインスタンスが渡されます．
また，`ISampleHub`は`IDisposable`なので，忘れずに`Dispose`でリソースを解放します．

```csharp
using System.Threading.Tasks;
using Grpc.Core;
using MagicOnion.Client;
using MagicOnionSample.Shared;
using UnityEngine;

namespace MagicOnionSample.Unity
{
    public class SampleEntryPoint : MonoBehaviour
    {
        public string host = "localhost";
        public int port = 5000;

        public string user = "Foo";
        public string room = "Bar";

        private Channel _channel;

        // Here
        private ISampleHub _hub;
        private ISampleHubReceiver _receiver;

        private async Task Start()
        {
            _channel = new Channel(host, port, ChannelCredentials.Insecure);

            var client = MagicOnionClient.Create<ISampleService>(_channel);
            var greet = await client.GreetAsync(user);
            Debug.Log(greet);

            // Here
            _receiver = new SampleHubReceiver();
            _hub = StreamingHubClient.Connect<ISampleHub, ISampleHubReceiver>(_channel, _receiver);
            await _hub.JoinAsync(user, room);
        }

        private async Task OnDestroy()
        {
            await _hub.DisposeAsync(); // Here
            await _channel.ShutdownAsync();
        }
    }
}
```

## サーバー側の実装

サーバー側では`ISampleHub`の実装を行います．
`SampleHub.cs`を作成し，`name`と`room`が与えられたら`Player`を作成して返すといった実装を行います．

`Broadcast`に`IGroup`のインスタンスを渡すことで，グループ内のすべてのクライアントに対してコールバックを呼ぶことができます．

```csharp
using System;
using System.Threading.Tasks;
using MagicOnion.Server.Hubs;
using MagicOnionSample.Shared;

namespace MagicOnionSample.Server.Hubs
{
    public class SampleHub : StreamingHubBase<ISampleHub, ISampleHubReceiver>, ISampleHub
    {
        private Player _player;
        private IGroup _room;

        public async Task JoinAsync(string name, string room)
        {
            _player = new Player {Name = name, Room = room};
            await Console.Out.WriteLineAsync($"Join {_player.Name} to the {_player.Room}");
            (_room, _) = await Group.AddAsync(_player.Room, _player);
            Broadcast(_room).OnJoin(_player);
        }
    }
}
```

## 動作確認

上記の動作確認と同じように，`dotnet run`コマンド等でサーバーを起動してUnityを実行すると，UnityのConsoleに`Welcome Foo!`と`Foo, bar`表示されたら成功です．
また，サーバー側のConsoleでは`Join Foo to the Bar`と表示されます．
以上で，サーバーとクライアントの1対多のApiコールができました．

# その他注意点

`List<T>`や`Array<T>`などをMessagePackに渡す場合は，シリアライズの時に`null`の場合，エラーが発生することがあります．プロパティの初期化子を使って初期化をすることで，シリアライズでエラーを回避することができます．

自作クラスのコンストラクタを実装する場合，コンストラクタ引数がないコンストラクタをMessagePackに渡すと，シリアライズ時にエラーが発生するため，引数があるコンストラクタに加えて，引数がないコンストラクタを作成する必要があります．


# まとめ

MagicOnionを使ってリアルタイム通信の世界に入門しました．

- UnityプロジェクトにインストールしたMagicOnionとMessagePackでコンパイルエラーが発生する場合は`MagicOnion.Client`に`MessagePack.Annotations`を追加する
- 1対1では`IService<T>`を使う
- 1対多では`IStreamingHub<T, U>`を使う
- MessagePackでは`null`に注意
- MessagePackではコンストラクタに注意

マルチプレイのゲームを作るときには有効活用したいです．
