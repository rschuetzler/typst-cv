// =============================================================================
// Ryan M. Schuetzler, Ph.D. — Academic CV
// Typst version, migrated from XeLaTeX
// =============================================================================
//
// COMPILING:
//   typst compile cv.typ --font-path fonts
// LIVE COMPILING:
//   typst watch cv.typ --font-path fonts
//
// BIBLIOGRAPHY APPROACH:
//   Publications are rendered using the Pergamon package, which provides
//   BibLaTeX-style bibliography management for Typst. All publications are
//   loaded from my-pubs.bib.
//   The print-bibliography() function with show-all and filter produces
//   separate sections for journal articles, conference proceedings, and
//   book chapters automatically, sorted by year (most recent first).
// =============================================================================

// ---------------------------------------------------------------------------
// PERGAMON BIBLIOGRAPHY SETUP
// ---------------------------------------------------------------------------
#import "@preview/pergamon:0.7.2": *

// All publications in one file
#add-bib-resource(read("zotero.bib"))

#let style = format-citation-authoryear()

// State to track the last-printed year so margin years only appear once per group
#let last-pub-year = state("last-pub-year", "")

// Base reference formatter: APA style
#let base-fref = format-reference(
  reference-label: style.reference-label,
  print-date-after-authors: true,
  print-identifiers: (),
  link-titles: false,
  print-eprint: false,
  name-format: "{family}, {given}.",
  format-quotes: it => it,
  format-journaltitle: it => emph(it) + [,],
  suppress-fields: ("eventtitle", "note", "extradate"),
  bibstring: ("in": "", "urlseen": "", "page": "p.", "pages": "pp."),
  volume-number-separator: "",
  format-fields: (
    "parsed-date": (dffmt, value, ent, field, opts, sty) =>
      if value != none and "year" in value { str(value.year) } else { none },
    "pages": (dffmt, value, ent, field, opts, sty) => {
      let label = if value.contains("-") or value.contains("–") {
        opts.bibstring.pages
      } else {
        opts.bibstring.page
      }
      if label != "" { [#label#sym.space.nobreak#value] } else { [#value] }
    },
    "number": (dffmt, value, ent, field, opts, sty) => [#("(" + value + ")")],
    "volume": (dffmt, value, ent, field, opts, sty) => emph(value),
    "parsed-author": (dffmt, value, ent, field, opts, sty) => {
      if value == none { none } else {
        let processed = value.map(d => {
          let given = d.at("given", default: "")
          let initials = given.split(" ").filter(p => p.len() > 0).map(p => {
            if p.ends-with(".") { p } else { p.at(0) + "." }
          }).join(" ")
          d + (given: initials)
        })
        dffmt(processed, ent, field, opts, sty)
      }
    },

  ),
  list-end-delim-two: ", & ",
  list-end-delim-many: ", & ",
)

// Wrapped format-reference that adds margin year annotations and [DOI]/[URL] link
#let cv-fref(index, reference) = {
  let base = base-fref(index, reference)
  let parsed-date = reference.fields.at("parsed-date", default: none)
  let year = if parsed-date != none and "year" in parsed-date {
    str(parsed-date.year)
  } else {
    reference.fields.at("year", default: "")
  }
  let doi = reference.fields.at("doi", default: "")
  let hdl = {
    let h = reference.fields.at("hdl", default: "")
    if h != "" { h } else if reference.fields.at("eprinttype", default: "") == "hdl" {
      reference.fields.at("eprint", default: "")
    } else { "" }
  }
  let url = reference.fields.at("url", default: "")
  let doi-link = if doi != "" {
    let doi-url = if doi.starts-with("http") { doi } else { "https://doi.org/" + doi }
    [ #link(doi-url)[#smallcaps[[doi]]]]
  } else if hdl != "" {
    // HDL starting with "10." is a DOI handle — use the DOI resolver
    if hdl.starts-with("10.") {
      [ #link("https://doi.org/" + hdl)[#smallcaps[[doi]]]]
    } else {
      [ #link("https://hdl.handle.net/" + hdl)[#smallcaps[[url]]]]
    }
  } else if url != "" {
    [ #link(url)[#smallcaps[[url]]]]
  } else { [] }
  let year-cell = context {
    let prev = last-pub-year.get()
    last-pub-year.update(year)
    if prev != year {
      place(dx: -1in, box(width: 1.0in, align(left, text(size: 8pt, year))))
    }
  }
  // Prepend year annotation to the first (and only) column from authoryear style
  ([#year-cell #base.at(0)#doi-link],)
}


// ---------------------------------------------------------------------------
// PAGE LAYOUT
// ---------------------------------------------------------------------------
#set page(
  paper: "us-letter",
  margin: (left: 1.5in, right: 1.0in, top: 1.0in, bottom: 1.0in),
  numbering: "1",
  number-align: center,
)

// ---------------------------------------------------------------------------
// FONTS
// ---------------------------------------------------------------------------
#set text(
    font: "Linux Libertine O",
  size: 10pt,
  lang: "en",
)

#set par(justify: true, leading: 0.65em)
#set block(spacing: 0.65em)

// ---------------------------------------------------------------------------
// LINK STYLING
// ---------------------------------------------------------------------------
#show link: set text(fill: rgb("#191970")) // MidnightBlue
#show "&": text.with(features: ("salt",)) // Fancy Linux Libertine ampersand

// ---------------------------------------------------------------------------
// HEADING STYLES
// ---------------------------------------------------------------------------
// h1 = \section*  → Large, medium weight, upright
#show heading.where(level: 1): it => {
  v(0.8em)
  block(breakable: false, below: 0.4em)[
    #text(size: 17.28pt, weight: "regular")[#it.body]
    #v(0.4em)
  ]
}

// h2 = \subsection* → normal size, small caps
#show heading.where(level: 2): it => {
  v(0.6em)
  block(breakable: false, below: 0.3em)[
    #text(size: 10pt, weight: "regular")[#smallcaps[#it.body]]
    #v(0.3em)
  ]
}

// h3 = \subsubsection* → large, medium weight
#show heading.where(level: 3): it => {
  v(0.4em)
  block(breakable: false, below: 0.2em)[
    #text(size: 12pt, weight: "regular")[#it.body]
    #v(0.2em)
  ]
}

// No numbering on headings
#set heading(numbering: none)

// ---------------------------------------------------------------------------
// HELPER: margin year annotation
// ---------------------------------------------------------------------------
// Places the year string in the left margin, matching the LaTeX \years{} command
#let years(body) = {
  place(dx: -1in, box(width: 1.0in, align(left, text(size: 8pt, body))))
}

// Helper for a generic entry with year in margin (keeps year + content together)
#let entry(year, body) = {
    block(breakable: false, above: 1.5em)[
    #years(year)
    #body
  ]
}



// =============================================================================
// DOCUMENT CONTENT
// =============================================================================

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------
#text(size: 20pt)[Ryan M. Schuetzler, Ph.D.]

#v(0.8em)

Department of Information Systems\
Marriott School of Management\
Brigham Young University\
Provo, UT #raw("84602") U.S.A.

#v(0.2em)
email: #link("mailto:ryan.schuetzler@byu.edu")[ryan.schuetzler\@byu.edu]\
#smallcaps[url]: #link("https://www.schuetzler.net")[https://www.schuetzler.net]

// ---------------------------------------------------------------------------
= Current Position
// ---------------------------------------------------------------------------
_Associate Professor_\
Department of Information Systems\
Marriott School of Management\
Brigham Young University

// ---------------------------------------------------------------------------
= Research Interests
// ---------------------------------------------------------------------------

In my research, I focus on how people respond to new technology, and how that technology can be built to interact with users most effectively.
My primary research focuses on human interaction with embodied conversational agents, robots, and chatbots, and the influence of those chat bots on users' feelings and behavior toward those systems.
I am interested to learn how people adapt their behavior, either consciously or unconsciously, as they interact with these types of novel systems.

// ---------------------------------------------------------------------------
= Areas of Specialization
// ---------------------------------------------------------------------------

Conversational Agents #sym.bullet Human-Computer Interaction #sym.bullet Human-AI Interaction

// ---------------------------------------------------------------------------
= Previous Appointments
// ---------------------------------------------------------------------------

#entry[2015--2020][University of Nebraska at Omaha, Assistant Professor]

// ---------------------------------------------------------------------------
= Education
// ---------------------------------------------------------------------------

#entry[2015][#smallcaps[Ph.D.] in Management Information Systems, University of Arizona]
#entry[2010][#smallcaps[MS] in Information Systems Management, Brigham Young University]
#entry[2010][#smallcaps[BS] in Information Systems, Brigham Young University]

// ---------------------------------------------------------------------------
= Grants, Honors & Awards
// ---------------------------------------------------------------------------

#entry[2019--2020][Principal Investigator, _The Role of Expectations in Shaping Impressions of Artificial Intelligence_,
University Committee on Research and Creative Activity, University of Nebraska at Omaha, \$5,000.]

#entry[2016--2019][Co-investigator, _Optimizing EHR Usability for Cardiac Care_,
Agency for Healthcare Research and Quality, \$571,835.]

#entry[2015--2018][Principal investigator, _Dynamic Interviewing Agents_,
Nebraska Research Initiative, \$200,000.]

#entry[2015][Co-investigator, _Decision Support Capabilities for National
Leadership_, National Strategic Research Institute, \$249,875.]

#entry[2011--2014][\$205,000 in research grants, Center for Identification
Technology Research]

#entry[2011][Science Foundation Arizona Graduate Research Fellow]

== Awards

#entry[2020][University of Nebraska at Omaha Alumni Outstanding Teaching Award]

#entry[][Outstanding officer award as President of the Midwest Chapter of the Association for Information Systems]

#entry[2018][Best paper for "Next-Generation Accounting Interviewing: A Comparison of Human and Embodied Conversational Agents (ECAs) as Interviewers" at American Accounting Association Midyear Meeting]

#entry[][Best paper for "Learning by Teaching through Collaborative Tutorial Creation: Experience using GitHub and AsciiDoc" at EDSIG Conference on Information Systems & Computing Education]

#entry[][Outstanding officer award as Secretary of the Midwest Chapter of the Association for Information Systems]

// ---------------------------------------------------------------------------
= Publications & Talks
// ---------------------------------------------------------------------------

#refsection(format-citation: style.format-citation)[

// ---- Journal Articles ----
== Journal articles
#last-pub-year.update("")
#print-bibliography(
  format-reference: cv-fref,
  label-generator: style.label-generator,
  show-all: true,
  filter: reference => reference.entry_type == "article",
  sorting: "ydn",
  title: none,
    grid-style: (row-gutter: 1.25em),
)


// ---- Book Chapters ----
== Book chapters
#last-pub-year.update("")
#print-bibliography(
  format-reference: cv-fref,
  label-generator: style.label-generator,
  show-all: true,
  filter: reference => reference.entry_type in ("incollection", "inbook"),
  sorting: "ydn",
  title: none,
    grid-style: (row-gutter: 1.25em),
)


// ---- Conference Proceedings ----
== Conference proceedings
#last-pub-year.update("")
#print-bibliography(
  format-reference: cv-fref,
  label-generator: style.label-generator,
  show-all: true,
  filter: reference => reference.entry_type == "inproceedings",
  sorting: "ydn",
  title: none,
    grid-style: (row-gutter: 1.25em),
)

] // end refsection


// ---- Software Products ----
== Software Products Created

#entry[2025][_Chattr Teach_. AI-based lecture support software to generate summaries of class lectures and learning materials to support student learning.]

#entry[2024][_Chattr Pro_. Web-based chatbot research and development platform to support academic study of human-chatbot interactions.]

#entry[][_Chattr Live_. Live feedback and polling platform to improve student engagement and invite student questions.]


// ---- Invited Presentations and Panels ----
== Invited Presentations and Panels

#entry[2022][_When Should a Chatbot Be Less Chatty_. Presentation at AMCIS Workshop on Artificial Intelligence and Human Interaction, Minneapolis, MN.]

#entry[2021][_The Value of Tailoring and Small Talk_. Presentation at the Dagstuhl Seminar: Conversational Agent as Trustworthy Autonomous System (Trust-CA).]

#entry[2019][_When Programs Collide: Competing Interests of Analytics and Security_. Panel at the annual conference of the Midwest Chapter of the AIS. Panel report published in _Communications of the Association for Information Systems_.]

#entry[][_Extending Engagement with Discussion Boards_. Presentation at the UNO STEM TRAIL Center Pedagogy Workshop.]

#entry[][_Fostering a Community of Inquiry with Discourse(.org)_. Presentation at the 2nd annual UNO Digital Learning Showcase.]

#entry[2018][_Developing Instructor Presence Online_. Presentation at the 1st annual UNO Digital Learning Showcase.]

#entry[][_Extending the Conversation about Teaching with Technology_. Panel at the University of Nebraska Technology and Pedagogy Symposium.]

#entry[2016][_Chatbot for Enhancing Voluntary Information Disclosure_. Webinar for the Center for Identification
Technology Research, an NSF Industry/University Collaborative Research Center.]

#entry[2015][_Lie to Me: Chatterbot Style_. Webinar for the Center for Identification
Technology Research, an NSF Industry/University Collaborative Research Center.]

#entry[2014][_Identifying and Reducing Patient Drug Seeking_. Panel for first-year
medical students at University of Arizona College of Medicine.]

#entry[][_A Mobile Interviewing Agent for Deception Detection_. Webinar for the
Center for Identification Technology Research, an NSF Industry/University Collaborative
Research Center.]

#entry[2012--2014][_Deception and Automated Credibility Assessment_. Fort Huachuca
Military Intelligence Captain's Career course.]


// ---------------------------------------------------------------------------
= Teaching
// ---------------------------------------------------------------------------

== Teaching Narrative

The primary courses I have taught are data communications/IT infrastructure
and computer security management. I have successfully adapted both courses for
online learning, and continue to teach in both modes. My courses involve a variety of activities,
including open access hands-on lab activities I have created to allow students to
see the concepts they learn about in action.

== Courses Taught
=== Brigham Young University

#entry[2021--present][IS 404 -- Data Communications (Overall rating: 4.7/5.0)]

=== University of Nebraska at Omaha

#entry[2017--2020][CYBR/ISQA 8546 -- Computer Security Management (Overall rating: 4.42/5.0)]

#entry[2015--2020][ISQA 3400 -- Business Data Communications (Overall rating: 4.55/5.0)]

#entry[2016--2020][ISQA 8310 -- Data Communications (Overall rating: 4.65/5.0)]

#entry[2016--2019][ISQA 4380 -- Distributed Systems and Technologies (Overall rating: 4.48/5.0)]

=== University of Arizona

#entry[2013--2015][MIS 307 -- Introduction to Business Data Communications (Effectiveness: 4.6/5.0)]

#entry[2012][MIS 111 -- Introduction to Management Information Systems (Effectiveness: 4.9/5.0)]

== Course Achievements
=== BYU

- Provide fully virtual lab activities for instruction during COVID-19 pandemic when in-person lab activities were impractical
- Add full module on AWS Cloud Practitioner materials, encouraging students to begin receiving certifications to enhance employment prospects (6 students certified in 2022)
- Introduced PollEverywhere to the classroom to allow in-person and remote students to interact, ask questions, and engage with material during lecture time

=== Omaha

- Transitioned IT Infrastructure, Computer Security Management, and Distributed Technologies classes to online learning
- Fully updated former data communications course to IT Infrastructure, including new content introducing operating systems and cloud computing.
- Created virtual labs for IT Infrastructure to allow students to gain hands-on experience with data communications (Creative Commons licensed, and available on #link("https://github.com/rschuetzler/datacom-labs")[GitHub])
- Created a discussion board using the open source Discourse program to provide a more flexible and dynamic conversation platform for student-student interactions
- Converted IT Infrastructure course to use Open Educational Resources (OER) to improve flexibility and reduce costs for students
- Online course featured in the 2020 UNO Chancellor's strategic planning forum

== Select Student Comments

#quote(block: true)[
I appreciated your passion and it encouraged me to work harder and study better for this
course...I fully digested the information you presented to us. After completing this
course, I am seriously considering spending more time in the areas you taught us because
I have found a curiosity for the area I did not imagine before.
]

#quote(block: true)[
I really enjoy class. The way the material has been amplified with your own knowledge
and the way the slides are structured really help me to pay attention, take notes, and
tell myself "Ooo, that's something I want to put down here. That's important."
]

#quote(block: true)[
Great teacher, made everything very easy to understand. Made class interesting and
fun. Kept everyone engaged in learning.
]

#quote(block: true)[
I really enjoyed that Ryan truly cared if his students understood what was going on and
comprehended the material.
]


// ---------------------------------------------------------------------------
= Service
// ---------------------------------------------------------------------------

== Conference and AIS Activities

- Mini-track chair (AMCIS 2018--present): Cognitive, Affective, and Conversational HCI
- Track Associate Editor (ICIS 2022): Design Research and Methods in Information Systems
- Track Associate Editor (ICIS 2021): Human-Robot Interaction & Digital Learning and IS Curricula
- Mini-track co-chair (HICSS 2019--2022): Design and Development of Collaboration Technologies
- President of the Midwest chapter of the Association for Information Systems (2019--2020)
- Secretary for Midwest chapter of the Association for Information Systems (2016--2018)
- Conference chair: Big XII+ Management Information Systems Symposium (2017, Omaha)

== Reviewing
=== Grants

- Dutch Research Council (2020)

=== Journals

- Information Systems Research
- International Journal for Human-Computer Interaction
- MIS Quarterly
- Journal of Management Information Systems
- Journal of the Association for Information Systems
- Computers in Human Behavior
- Decision Support Systems
- Journal of the Midwest Association for Information Systems
- ACM Transactions on Management Information Systems
- Group Decision & Negotiation
- Journal of Nonverbal Behavior
- IEEE, SMC-A

=== Conferences

- EDSIG Conference on Information Systems & Computing Education
- International Conference on Information Systems
- Hawaii International Conference on System Sciences
- Americas Conference on Information Systems
- European Conference on Information Systems
- AIS Special Interest Group on Human-Computer Interaction (SIGHCI)

== Department/University

- IS Alumni Council Chair (2024--present)
- IS Undergraduate Admissions Council member (2021--present)
- IS Graduate Admissions Council member (2021--present)
- ISQA Department Undergraduate Program Committee Chair (2017--2020)
- IS&T Doctoral Program Committee Member (2019--present)
- IS&T Faculty Liaison for Instructional Design (2017--2019)
- IS&T Advisory Committee Member (2018--2019)
- Biomedical Informatics Doctoral Program Committee Member (2018--2019)
- ISQA Department Undergraduate Program Committee Member (2016--2017)
- UNO Success Academy Faculty Presenter (2016--2017)

== Community

- Omaha Python User Group: Arranged campus hosting for monthly meetings and presented on conversational agent research (2018)


// ---------------------------------------------------------------------------
= Technical and Other Skills
// ---------------------------------------------------------------------------

- Programming languages: Elixir, Python, R, Node.js
- Frontend programming: Vue, TailwindCSS
- AWS (Cloud Practitioner Certified)
- Web application development with Elixir/Phoenix and Python/Django
- TCP/IP networking (previously CCNA certified)
- SQL & database management
- Linux and Windows servers
- Spanish: Moderate proficiency


// ---------------------------------------------------------------------------
// FOOTER
// ---------------------------------------------------------------------------
#v(1fr)

#align(center, text(size: 8pt)[
  Last updated: #datetime.today().display("[month repr:long] [day], [year]") #sym.bullet
  Typeset in #link("https://typst.app")[Typst]
])


// ---------------------------------------------------------------------------
// (Bibliography is handled by Pergamon — no hidden bibliography needed)
// ---------------------------------------------------------------------------
