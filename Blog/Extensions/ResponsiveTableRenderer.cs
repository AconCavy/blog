using Markdig.Extensions.Tables;
using Markdig.Renderers;

namespace Blog.Extensions;

public class ResponsiveTableRenderer : HtmlTableRenderer
{
    protected override void Write(HtmlRenderer renderer, Table table)
    {
        renderer.EnsureLine();
        renderer.WriteLine("<div class=\"table-responsive\">");
        base.Write(renderer, table);
        renderer.WriteLine("</div>");
    }
}
