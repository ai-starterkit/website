---
# This page's words, as an ordered list of sections. CONTRIBUTING.md explains each section type.
# Links take a page ID (a file name in _pages/, such as policy), a web address or an email address.
browser_title: Technology Architecture
description: Figure out which tools and architectures fit the problems you want AI to solve, starting with the systems you already run.
sections:
  - type: hero
    heading: Technology Architecture
    lead: What enterprise AI stacks could look like for broad-access institutions, such as community colleges and HBCUs, with templates and tools that make them attainable for institutions with limited technical capacity.
  - type: bot
    id: architecture-bot
    heading: Architecture Bot
    credit: Developed with Ed Advancement and a working group of campus technology leaders
    body: In the near term, the working group is defining the reference materials, intake questions and decision criteria behind an advisory bot that helps institutional IT teams translate AI use cases into candidate early architectures. It will help institutions in the AI Starter Kit Implementation Pilot gain experience building and deploying AI solutions.
    steps:
      - title: Step 1 · Describe
        text: "The problems you want to solve with AI, and your current environment: diagrams, documentation or a few quick questions."
      - title: Step 2 · Map capabilities
        text: The bot translates your use cases into the capabilities you need, described independently of any product or vendor.
      - title: Step 3 · Compare options
        text: Several candidate architectures, each with the capabilities it covers, its tradeoffs and the criteria that would favor it.
    outputs_heading: "Each option the bot suggests includes:"
    outputs:
      - A short summary
      - A diagram of the main components and how data moves between them
      - How it works and connects to your current systems
      - Which capabilities it covers, and which it leaves open
      - "Tradeoffs: cost, staffing and skills, time to value, vendor lock-in, privacy and security, and accuracy risk"
      - When an institution should choose it
    button: Request access to the Architecture Bot →
    link: https://shrsvc.educationfinanceinstitute.org/register/?id=8252012c-94e7-48e3-9cd0-1cc8d4ee324f
  - type: examples
    id: example-architectures
    heading: Example architectures
    subheading: The working group is collecting reference architectures from member institutions and will review them together, starting at the October 27 convening. Examples will appear here once the group has agreed on them.
    examples:
      - title: Large State University
        show: false
        tags:
          - Campus chat interface
          - Research university
          - Students · Faculty
        diagram: large-state-university
        facts:
          - term: Users
            text: "31,400: 30,000 students and 1,400 faculty"
          - term: Cost and timeline
            text: Target of $3 per user per month. About six months of build, from March 2025 to launch in September 2025.
          - term: What it would take elsewhere
            text: An existing cloud agreement, a small in-house technical team plus a retrieval partner, a FERPA review with a no-training-on-student-data commitment, and a narrow starting scope tied to a clear cost case.
          - term: Source
            text: AWS Public Sector Blog, vendor case study. Last checked 24 September 2026.
    cards:
      - id: snapshot-template
        show: false
        tag: Snapshot template
        heading: Every example covers eight fields
        fields:
          - What it is
          - Institution type
          - Who has access
          - Number of users
          - How it's built
          - Cost and timeline
          - What it would take elsewhere
          - Source and date last checked
      - id: tech-station
        tag: From the July 2026 convening
        heading: The Tech station flip charts
        body: All five sheets from the Tech station at the Durham gallery walk, transcribed and paired with the original photos.
        button: View in Google Drive ↗
        link: ""
  - type: text
    id: open-stack
    badge: Early stage
    heading: Toward an open education AI stack
    body: |-
      Over time, the working group plans to extend this work into a fuller toolkit for designing and adopting a long-term AI stack. That likely means finding gaps in today’s market and filling them with open-source components that institutions can run in their own environments.

      The group is taking stock of existing efforts in this space and will set next steps after the October 27 convening.
  - type: cards
    id: architecture-resources
    show: false
    style: source
    columns: 3
    heading: Architecture resources
    button: Visit ↗
  - type: cta
    id: join
    style: join
    kicker: Open to everyone
    heading: Join the Technology Architecture initiative
    body: Help IT teams plan the systems behind campus AI.
    button: Join the initiative →
    link: contact
    points:
      - Join discussions with technology leaders facing the same decisions.
      - Give feedback on the Architecture Bot and the example architectures.
      - Share your institution's architecture as an example for others.
      - Try new versions of the Architecture Bot before they launch.
---
