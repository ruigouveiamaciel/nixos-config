/**
 * SearXNG Web Search Extension
 *
 * Adds a `web_search` tool (callable by the model) and a `/websearch` command
 * that query a SearXNG instance via its JSON API.
 */

// ============================================================================
// CONFIGURATION — edit these to match your setup and preferences
// ============================================================================

/** Base URL of your SearXNG instance (no trailing slash) */
const SEARXNG_URL = "http://10.0.50.42:8888";

/** Default search language, e.g. "en", "de", "all" */
const DEFAULT_LANGUAGE = "en";

/** Default categories to search (comma-separated), e.g. "general", "general,it" */
const DEFAULT_CATEGORIES = "general,it";

/** Maximum number of results returned to the model */
const MAX_RESULTS = 12;

/**
 * Preferences hash from your SearXNG preferences page
 * (open /preferences on the instance, choose "copy preferences hash", paste below).
 * Sent as the `preferences` URL parameter on every search, so your engines,
 * language, time range, etc. apply. Leave empty to ignore.
 */
const PREFERENCES_HASH =
  "eJx1WMmS67oN_Zp4o3pd9-VmqCy8SiXvA_L2KoiEJV5RhJqDbfbXB6Qm0nIvetChCIIYDgAJ8NiTVeiuPRq0oC8aTB-gxyuaiyYBOv8HwZOgadbo8doT9RovN7grQaa16Ejf0V4vauKN7WzpGa9_2oCXCf1A8vrHf_68OLihQ7BiuP64-AEnvDqVBF54f9DetSzK4KP10F3_C9rhRZI6hBPw4wfZ_rJsa52PrJsEO14EGo-2Ba16M_H_y-GfAW1slWm98vzmInNRIZ0llrvH1qFGse4ZyI8Y3fWupkuwur2RncB7ZfrrbNH7eJHKQadRtmh6ZdhwP__xYxXarjb8y1__vYPNXUkk17bLX176-48f87NtiW1g-fFfPfRt60go0M2EUgGD0AkTB0yXKoSCuAVTSAI9swaNViY8mxnEyNbnk5RPa8ZBm-yZX5zHZlLWkt1WZ7Zgw78b58nivgfYnxK2R-uV4P-TU93y7Dx4xbYrwEilih0oGU5As7xebFvgEdRtO61TWqWf4n4dm72Sxc9vRCU0XXS_bkZOdu-UF0PwWENdECP6TQcCKy2CrO1ewS-e6uauetVL1bPSN6WzcjSj4eh1WCict34IIT5kqYwAMcSG3KsnxYC3kVJ4bSEjLDln8cbKCIVG4II95F1x_hTaRJzLR4n4la4wBadEfs7-dIdkiTmlS_NK2TcSb8qo5HlXyuOjo9B0jn5kZZQsxLKR009PzQMrexUrJ8cWaydnVhIhHXOctgT3BDNv4N9Jn4l-qTmZ_XiLcxojlrr8XmTlDZzvyJfLN2kpXSo7he0hs48PV-_Q-SbH0ukix1L2yuGctOAH8BMzZSXKYgdaV5qtWJ0FO3o-U7PXRZXGN63EaEvAIjaObv4BFhvJsoRPZLle3yozKijZ4RaNrJSKsYiAHjowX1C-0KP6GpiTi5fQqOAOE_CzJ1qP7NU8xOK8nkkdun3RI6cUTdvz9KyOIsr5W56Va9jLS4ycnbfiJyuuuHDf75k1xMSyWyqX8EScraU8rjNoE7W8ZuAAnYX0a5UyMD-gXXy9APjcuMKyEPehNqMN6y3zQ5KrbqUNlW5mcn4PmSH0XNP6G4htT4E0Ejw49O7NkmPO2glLTbI7DK2mPpSBpQwUl-astMwslVKfKpZV4JdyAx3yRg5UcEXeaZym2LDvp5A4KqnxwtHLG8ExD3-zlqzw3VqSzIH4ZlmxX2xsUgg5VWrEZrlXsa6pcx4_7GYiHYSSVU2Ann2T8n-758QMRJLMN3rvywO4wUP_5g30IGYw65GTSmWDE7rRzNcH-mQGD_JIuom-BlXqPj2mrqIbkwNJUOEjEwGKoiejw7K0kdYwbYU-lUTuKp9l9UrYas7ypATzNbBwf4IszlSYe6mXym1VfMYnlrQyK_ErTB2VSOoXMe_YPDCrlDsdxEKwejJtxT29j-0LfqKEmaRgf5TFaA4dl_n7qtpn4Ha1vGEGzvzx-QBTFZ8M1Py-QO-3nlWzyK2PPXZb8j7RK7MOlXdbivkUnfIVO3KTfBucP5GTw1nB1gHsp3HGzkw1qbsUYyGceqq6wwyc77DApzss8APZxgdn5SOcgbloANwYumB8WK3OLbsIzn3MkaeRLfIFSBk_NtrYCtusfhtI4xm36g4iPl4qbwGfb1Eunu7iaYzkiQ01phTdQo6HHSW50NqFcTbYJ5GO711Zr0RXa_iKe31w47k7O9CzzsXaWeVjrQrEYBxXNFc0qBGMxKoCL8j5vBV_6X0iDFSNFRKUjhMts8euEA9pWLLQQ3UVfTzUqDqi0b2CbkaRC8U38EFMCU79e46E4m3SN8uUpueh4nmphP8iU2XOFLmF49ap8ZaHMm69sOqTfv_585_Pw9MySDRlOn4ZmCpxqW-YlU7N6faWyVMZc_896PRemqN8zAW7A7fVcgP3eq7JwNknC1y5eIHOpBK62OPkduJF60NXMn8uRqzlmEaT3PvvS5Fzow4REc_KWGZujRWR6fQpoNy5fEAYgnmZl0v8DcnkUK5T40FPNZJhxm5cNGRi6r33bCLyqSt_MwWG5yPPqrvwO48KeS5fTXMPQ7iXJ2XgrNQCnwydwnDiEayU8AVzKvHV9GnZTyfg4zwyZ_g8IWe4cryjYAXy2LxNyP5vxXQ7j_1HT0V9c2icsNyFfYbCcKw5cmfKrUe6x4pfuAuovqOAMeCa5BOVLrGdkflm-cSx7F5iWT15Ui4AsE91LzOX5w0pYJoPVklvr0PgYSEREtfWkSgpNdjNELbxAoPlvmOexCs1pAx7P85-M-RWxkXPnMZ9jylsxZPMca4giR3avh4fKhnHFPJmluHaQBpsqfUktwJo5m1amoCHOdzGi9yf8bx3tPt1n5bWuKvhgRHWLwL1uvM8OvopFeRl-p5looTjpXngwmf21SyqkdyJKLMkxBEERy0N3ZR4s5AS5833FqSiprP0cOXnDY5dDoG6u3XcE4_EZHbT9NiCNvAQEtxuAIdsEB6Q35mPu_hEx3uho_BCeDtSRl3lsQR8Bqrbq1x-cq69oJnYU1e8HZkrEsX0ofVlf-pZ2B_ndC8X31LLtghBptGxVH1bevnY8SArjSpau4f39kMVlYvb-XXeOT6ZzjpwrrsrNzitGFCMOwlsKwK0CFwjKYlIo826ktsM5VvuPtl5fhkFoF2-ED-YcZJzuMCmxG3Th1vLNfe-DKAmf7zC__H8o7dWtmWU0hZuIdpUsS_ckHHsXv8PyViyrw==";

// ============================================================================

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type, type Static } from "typebox";

const Params = Type.Object({
  query: Type.String({ description: "Search query" }),
  categories: Type.Optional(
    Type.String({
      description: `Comma-separated categories to search (default: "${DEFAULT_CATEGORIES}"). Available categories: general, images, videos, news, it, science.`,
    }),
  ),
  language: Type.Optional(
    Type.String({
      description: `Search language, ISO code (default: "${DEFAULT_LANGUAGE}")`,
    }),
  ),
  pageNumber: Type.Optional(
    Type.Number({ description: "Results page number (default: 1)" }),
  ),
});

interface SearxResult {
  title?: string;
  url?: string;
  content?: string;
}

interface SearxResponse {
  results?: SearxResult[];
  corrections?: string[];
}

function cut(text: string, max: number): string {
  return text.length <= max ? text : text.slice(0, max - 1) + "…";
}

async function search(
  params: Static<typeof Params>,
  signal?: AbortSignal,
): Promise<string> {
  const url = new URL(`${SEARXNG_URL}/search`);
  url.searchParams.set("q", params.query);
  url.searchParams.set("format", "json");
  url.searchParams.set("language", params.language ?? DEFAULT_LANGUAGE);
  url.searchParams.set("categories", params.categories ?? DEFAULT_CATEGORIES);
  url.searchParams.set("safesearch", "0"); // always off, overrides instance default
  url.searchParams.set("pageno", String(params.pageNumber ?? 1));
  if (PREFERENCES_HASH) url.searchParams.set("preferences", PREFERENCES_HASH);

  const response = await fetch(url, {
    headers: { Accept: "application/json" },
    signal,
  });
  if (!response.ok) {
    throw new Error(
      `SearXNG returned HTTP ${response.status}. ` +
        `Make sure "json" is in the instance's search.formats (settings.yml).`,
    );
  }
  const body = (await response.json()) as SearxResponse;

  if (!body.results?.length) {
    if (body.corrections?.length) {
      return `No results. Did you mean: ${body.corrections[0]}?`;
    }
    return `No results found for "${params.query}".`;
  }

  const results = body.results.slice(0, MAX_RESULTS);
  const text = results
    .map(
      (r) =>
        `## ${cut(r.title ?? "(no title)", 160)}\n` +
        `URL: ${r.url ?? "n/a"}\n` +
        cut((r.content ?? "").replace(/\s+/g, " ").trim(), 400),
    )
    .join("\n\n");

  const omitted = body.results.length - results.length;
  return omitted > 0
    ? `${text}\n\n[${omitted} more results omitted. Use pageNumber to see the next page.]`
    : text;
}

export default function searxngExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "web_search",
    description:
      `Search the web with SearXNG (${SEARXNG_URL}). ` +
      "Returns titles, URLs and snippets. Use for current events, documentation, " +
      "package lookups, or anything outside local files.",
    parameters: Params,
    renderCall(args: Static<typeof Params>, theme) {
      let text = theme.fg("toolTitle", theme.bold("web_search "));
      text += theme.fg("accent", `"${args.query}"`);
      const extras = [
        args.categories,
        args.language ? `lang=${args.language}` : undefined,
        args.pageNumber ? `page=${args.pageNumber}` : undefined,
      ].filter(Boolean);
      if (extras.length) text += theme.fg("muted", ` ${extras.join(" ")}`);
      text += "\n";
      return new Text(text, 0, 0);
    },
    async execute(_toolCallId, params, signal) {
      return {
        content: [{ type: "text", text: await search(params, signal) }],
        details: undefined,
      };
    },
  });

  // Manual search from the prompt: /websearch [query]
  pi.registerCommand("websearch", {
    description: "Search the web via SearXNG",
    handler: async (args, ctx) => {
      const query = args?.trim();
      if (!query) {
        ctx.ui.notify("Usage: /websearch <query>", "warning");
        return;
      }
      try {
        ctx.ui.notify(await search({ query }), "info");
      } catch (err: any) {
        ctx.ui.notify(
          `websearch failed: ${err?.message ?? String(err)}`,
          "error",
        );
      }
    },
  });
}
