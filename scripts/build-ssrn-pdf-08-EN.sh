#!/bin/bash
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin LC_ALL=en_US.UTF-8
cd /Users/lizhuojun/dev/huadian/docs/articles/preprints || exit 1
SRC=08-dual-reverse-calculation-pattern-EN.md
OUT=08-dual-reverse-calculation-pattern-EN-v1.0-2026-10-11.pdf
python3 - "$SRC" /tmp/ssrn_v1.md <<'PY'
import re,sys
s=open(sys.argv[1],encoding='utf-8').read()
# header: replace repo revision note with SSRN version note
s=re.sub(r'> \*\*Revision note \(2026-08-19\)\.\*\*.*?\n>\n> \*\*v1\.0 \(2026-10-11\)\.\*\*[^\n]*\n',
 '> **Version 1.0 (2026-10-11).** This version supersedes the one posted to SSRN on 2026-07-14. Since that posting the contribution has been repositioned from "an anomaly is documented" to "a mechanism already established in the accounting literature as *real earnings management* is measured in a setting where the output is a physical quantity and the specification is a published number"; the corresponding literature was added (Section 7.1, Section 10). No datum, computation, or detection rule changed. **Not peer reviewed.** A public comment window ran 2026-08-16 to 2026-09-30 (github.com/lizhuojunx86/huadian/discussions/19) and received 0 comments; the disposition log is in the repository. Version 1.0 marks the author\'s decision to freeze the text, not peer endorsement.\n', s, count=1, flags=re.S)
assert 'Version 1.0 (2026-10-11)' in s, 'header replace failed'
s=s.replace('```mermaid','```text').replace('★','(*)')
s=s.replace('∝','$\\propto$').replace('CaSO₄·2H₂O','CaSO$_4$·2H$_2$O')
s=s.replace('₂','$_2$').replace('₄','$_4$')
s=s.replace('Project repository: https://github.com/lizhuojunx86/huadian.','Project repository:'+chr(92)+chr(10)+'https://github.com/lizhuojunx86/huadian.')
# remove emoji/symbols xetex fonts may lack
s=re.sub('[\U0001F300-\U0001FAFF☀-➿]','',s)
import textwrap
out=[];inblock=False
for line in s.split(chr(10)):
    if line.startswith('```'):
        inblock=not inblock; out.append(line); continue
    if inblock and len(line)>74:
        ind=len(line)-len(line.lstrip())
        out.extend(textwrap.wrap(line,width=74,initial_indent='',subsequent_indent=' '*(ind+4),break_long_words=False,break_on_hyphens=False) or [line])
    else: out.append(line)
s=chr(10).join(out)
open(sys.argv[2],'w',encoding='utf-8').write(s)
print('preprocessed', len(s))
PY
cat > /tmp/ssrn_hdr.tex <<'TEX'
\usepackage{xurl}
\usepackage[htt]{hyphenat}
\usepackage{etoolbox}
\AtBeginEnvironment{longtable}{\small}
\let\oldtexttt\texttt
\renewcommand{\texttt}[1]{\oldtexttt{\sloppy #1}}
TEX
pandoc /tmp/ssrn_v1.md -o "$OUT" --pdf-engine=tectonic \
  -V mainfont="Times New Roman" -V monofont="Menlo" -V sansfont="Helvetica Neue" \
  -V geometry:margin=1in -V fontsize=11pt -V linkcolor=blue -V urlcolor=blue \
  -V colorlinks=true -V monofontoptions="Scale=0.85" \
  --include-in-header=/tmp/ssrn_hdr.tex --metadata title="" 2>&1 | tail -20
echo "exit=${PIPESTATUS[0]}"
ls -la "$OUT" 2>&1
pdfinfo "$OUT" 2>/dev/null | grep -i pages
echo BUILD_DONE
