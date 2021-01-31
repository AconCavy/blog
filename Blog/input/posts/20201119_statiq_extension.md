---
Title: Statiqがmarkdownから生成するhtmlのカスタマイズ
Published: 11/19/2020
Updated: 11/19/2020
Tags: [.NET, Statiq] 
---

# はじめに

Statiqがmarkdownから生成するhtmlの任意のタグにクラスを追加する方法の備忘録

# 方法

`Bootstrapper`において、`Statiq.Web`でWebサイトを生成するメソッドである`CreateWeb()`では、markdownに関わるModuleの`RenderMarkdown`を`Templates`内で設定している。
そのため、`ConfigureTemplates()`を通じて、予め設定されたModuleを上書きすることで好みの設定を反映することができる。
Statiqでは、markdownを生成するために[markdig](https://github.com/lunet-io/markdig)を使っているようなので、markdownの設定を追加するには`IMarkdownExtension`を継承したクラスを`Rendermarkdown.UseExtension<TExtension>()`に渡す必要がある。

今回は、`<img>`タグをレスポンシブ対応と、`<table>`タグにクラスを追加するために、markdigの`BootstrapExtension`を設定に追加する。

```csharp
public static async Task<int> Main(string[] args) =>
    await Bootstrapper.Factory
        .CreateWeb(args)
        .ConfigureTemplates(templates =>
        {
            // 新しい設定のModuleを作成
            // デフォルトはUseExtensionsのみ
            var markdownModule = new RenderMarkdown()
                .UseExtensions()
                .UseExtension<BootstrapExtension>() // bootstrap
                .UseExtension<PrismJsExtension>(); // オリジナル
            if (templates.ContainsKey(MediaTypes.Markdown)) 
                templates[MediaTypes.Markdown].Module = markdownModule; // 既にあるならば書き換え
            else 
                templates.Add(MediaTypes.Markdown,
                    new Template(ContentType.Content, Phase.Process, markdownModule)); // 無ければ追加
        })
        .RunAsync();
```

また、`prism.js`のコードブロックに行数を表示するクラスの`line-number`を追加するために、新しく`PrismJsExtension.cs`を作成し、`BootstrapExtension`に倣い、`MarkdownObject`が`CodeBlock`であれば`line-numbers`をクラスに追加するメソッドの`PipelineOnDocumentProcessed()`markdigの生成パイプラインにデリゲートを追加する。

```csharp
// PrismJsExtension.cs
using Markdig;
using Markdig.Renderers;
using Markdig.Renderers.Html;
using Markdig.Syntax;

namespace Blog.Extensions
{
    public class PrismJsExtension : IMarkdownExtension
    {
        public void Setup(MarkdownPipelineBuilder pipeline)
        {
            pipeline.DocumentProcessed -= PipelineOnDocumentProcessed;
            pipeline.DocumentProcessed += PipelineOnDocumentProcessed;
        }

        public void Setup(MarkdownPipeline pipeline, IMarkdownRenderer renderer)
        {
        }

        private static void PipelineOnDocumentProcessed(MarkdownDocument document)
        {
            foreach (var node in document.Descendants())
            {
                if (node is CodeBlock)
                {
                    node.GetAttributes().AddClass("line-numbers"); // 行数表示のクラスを追加
                }
            }
        }
    }
}

```

以上の2つの設定を追加してビルドすることで、bootstrapによる`<img>`タグのレスポンシブ対応、`<table>`タグのレイアウト、prism.jsの言語を指定したコードブロックに行数が表示されるようになる。

# まとめ

StatiqのBootstrapperにて`ConfigureTemplates()`からテンプレートのmarkdownに関わるModuleを書き換えることで、markdownからhtmlを生成する設定を変更することができ、`RenderMarkdown.UseExtension<TExtension>()`に`IMarkdownExtension`を継承したクラスを設定することで、htmlタグのクラス等を変更することができる。
