Title: ブログのレイアウト変更とStatiqを使った静的サイトの生成
Published: 11/8/2020
Updated: 11/8/2020
Tags: [Statiq, Github Pages, Github Actions]
---

# はじめに

前回のブログから一度も更新せずに3か月経ち，サイト生成を `Wyam` から `Statiq` に変えたついでに，サイトのレイアウトを頑張ってアレンジしたので記事を書きます．

# Statiq

[Statiq](https://statiq.dev/) は [前回の記事](20200819wyamblog) で紹介した `Wyam` をリブランディングし，機能の追加に柔軟性を持たせたフレームワークだそうです．
大きく3つのフレームワークに分かれており，基礎となる `Statiq.Framework`，一般的なWebサイト生成のための `Statiq.Web`，ドキュメントサイト生成のための `Statiq.Doc` に分かれています．

`Statiq.Framework` はMITライセンスで公開されている一方，`Statiq.Web` と `Statiq.Doc` は [License Zero Prosperity Public License](https://licensezero.com/licenses/prosperity) (Public License) と [License Zero Private License](https://licensezero.com/licenses/private) (Private License)` のデュアルライセンスを取ります．
そのため，商用利用の場合は，はじめ30日間の無料体験期間のあと，開発者一人当たり50ドルのPrivate Licenseを取得する必要があります．
非商用の場合は他のPermissive Open-source License(MITやApache等)と同様のライセンスで利用することができます．
詳しくは[こちら](https://github.com/statiqdev/Statiq.Web/blob/main/LICENSE-FAQ.md).

## 使い方

Wyamは.NET上にツールをインストールして実行するのに対して，Statiqの場合はコンソールアプリケーションとして実行します．

```sh
dotnet new console --name Blog
dotnet add package Statiq.Web --version x.y.z
```

そして，エントリポイントの `Program.cs` にBootStrapeprを追記します．

```csharp
using System.Threading.Tasks;
using Statiq.App;
using Statiq.Web;

namespace Blog
{
    public static class Program
    {
        public static async Task<int> Main(string[] args) =>
            await Bootstrapper.Factory
                .CreateWeb(args)
                .RunAsync();
    }
}
```

次に，`./input/` ディレクトリ内に `index.md` を作成し，適当な内容を書いて保存します．

```
Title: Hello Statiq
---
Hello world!
```

Wyamと同様に，ファイル上部にFront Matterを記述することで，記事タイトルやタグといったメタ情報を付与することができます．

```sh
dotnet run -- preview
```

そして，プロジェクトを実行することでローカルホスト上で静的サイトがホスティングされます．(デフォルトでは `localhost:5080`)

素の状態では，テーマは存在しないので，`./theme/input/` にWebサイトのテーマを用意する必要があります．

サンプルとして，公式テーマの[CleanBlog](https://github.com/statiqdev/CleanBlog)を `./theme/` ディレクトリ内に配置してプロジェクトを実行することで，WyamのCleanBlogテーマと同様のWebサイトを生成することができます．

## Github Pagesへの展開

Statiq.Webでは，公式でGithub Pagesへのデプロイ方法が用意されています．

Wyamの時と同様に，設定ファイル(今回は `settings.yml`)に設定を追記する必要があります．
```
Host: aconcavy.github.io // github pagesのホスト
LinkRoot: /Blog // バーチャルパス
LinksUseHttps: true

GitHubOwner: AconCavy // ユーザ名
GitHubName: Blog // リポジトリ名
GitHubToken: => Config.FromSetting<string>("GITHUB_TOKEN") // これはこのまま
GitHubBranch: gh-pages // 生成先ブランチ
```

Github Actionでは次のようなワークフローを指定します．
この時に，`GitHubBranch`で指定したブランチは，存在しない場合はエラーが吐かれるので，先にブランチを作成しておきましょう(5敗)．

```yaml
name: deploy

on:
  push:
    branches:
      - main

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - name: Setup .NET Core
      uses: actions/setup-dotnet@v1
      with:
        dotnet-version: 3.1
    - name: Deploy
      run: dotnet run -p Blog -- deploy
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

ワークフローが成功すると，指定したブランチにファイルが生成されるので，リポジトリの設定からGithub Pagesのブランチを指定します．
すべて成功すると，`{user}.github.io/{repository}` (今回は[aconcavy.github.io/Blog](https://aconcavy.github.io/Blog/)`)にサイトが表示されます．

サイトのテーマがうまく適用されない場合は，設定ファイルの `Host` や `LinkRoot` を見直すといいでしょう．

# まとめ

Statiqで作成した静的Webサイトを，GitHub ActionsとGitHub Pagesデプロイする方法をまとめました．

Wyamと比べてカスタマイズの自由度が高いみたいだけど，ドキュメントを調べても調べたいことにいまいち辿り着かないので，ドキュメントが豊富になればもっと使いやすくなりそうです．APIリファレンスとかも欲しい．
まだプレビュー段階なので今後に期待しています．

# あとがき

Webフロントなんもわからんマンだったので，CleanBlogのテーマを基にコードのシンタックスを変更したりしていたら3,4日ぐらいかかりました．おかげでWebデザインを学ぶことができたので，ちょっと前進でしょうか．

画像がレスポンシブ対応してないから前の記事をスマホでみると横に広くなってしまうので修正したいけど，Statiqでmarkdownから生成されるhtmlにタグを追加したいけどどうやるんだろうね．