{%- comment -%} Docs: latestDocs is site-relative (use it with relative_url); docsBase is absolute, for deep links. {%- endcomment -%}
{%- assign docsPath = '/docs/rook/latest-release' -%}
{%- assign latestDocs = docsPath | append: '/' -%}
{%- assign docsBase = site.url | append: docsPath -%}
{%- assign gettingStartedLink = docsBase | append: '/Getting-Started/quickstart/' -%}
{%- assign blogLink = 'https://blog.rook.io/' -%}
{%- assign communityMeetingLink = 'https://github.com/rook/rook#community-meeting' -%}
{%- assign calendarLink = 'https://zoom-lfx.platform.linuxfoundation.org/meetings/rook?view=month' -%}
{%- assign contributeLink = 'https://github.com/rook/rook/blob/master/CONTRIBUTING.md#how-to-contribute' -%}
{%- assign firstIssueLink = 'https://github.com/rook/rook/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22' -%}
{%- assign discussionLink = 'https://github.com/rook/rook/discussions' -%}
{%- assign featureRequestLink = 'https://github.com/rook/rook/issues' -%}
{%- assign newIssueLink = 'https://github.com/rook/rook/issues/new/choose' -%}
{%- assign githubLink = 'https://github.com/rook/rook' -%}
{%- assign slackLink = 'https://slack.rook.io/' -%}
{%- assign twitterLink = 'https://twitter.com/rook_io' -%}
{%- assign adoptersMdLink = 'https://github.com/rook/rook/blob/master/ADOPTERS.md' -%}
{%- assign governanceLink = 'https://github.com/rook/rook/blob/master/GOVERNANCE.md' -%}
{%- assign securityLink = 'https://github.com/rook/rook/blob/master/SECURITY.md' -%}

{%- assign cloudicalLink = 'https://cloudical.io/' -%}
{%- assign cncfLink = 'https://www.cncf.io' -%}
{%- assign clysoLink = 'https://clyso.com/en/' -%}
{%- assign cybozuLink = 'https://cybozu.com' -%}
{%- assign redHatLink = 'https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation' -%}
{%- assign upboundLink = 'https://upbound.io' -%}

{%- comment -%} Live labels from _data/live_stats.json when present, else the fallbacks in _data/stats.yml. {%- endcomment -%}
{%- assign stats = site.data.stats -%}
{%- assign live = site.data.live_stats -%}
{%- assign latestMinor = live.latest_minor | default: stats.latest_minor -%}
{%- assign releaseNotesLink = live.release_url | default: stats.release_url -%}
{%- assign starsCell = stats.cells | where: "live", "stars" | first -%}
{%- assign starsLabel = live.stars | default: starsCell.number -%}
