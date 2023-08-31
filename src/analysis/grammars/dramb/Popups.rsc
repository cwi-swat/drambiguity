module analysis::grammars::dramb::Popups

import salix::util::WithPopups;
import analysis::grammars::dramb::DrAmbiguity;

str popupStyle() 
    =   ".tooltip {
        'background: var(--info);
        'color: black;
        'font-weight: normal;
        'padding: 4px 8px;
        'font-size: 13px;
        'border-radius: 4px;
        'opacity: 1;
        'max-width: 200px;
        '}
        '.large-tooltip .tooltip-inner {
        'max-width: 20px;
        '}
        '@media screen and (max-width: 300px) {
        '.large-tooltip .tooltip-inner {
        '  max-width: 100%;
        '}
        '}
        '.arrow,
        '.arrow::before {
        '  position: absolute;
        '  width: 8px;
        '  height: 8px;
        '  background: inherit;
        '}
        '.arrow {
        '  visibility: hidden;
        '}
        '.arrow::before {
        '  visibility: visible;
        '  content: \'\';
        '  transform: rotate(45deg);
        '}";

Popups popups(Model m) 
    = [
        *[*sentencePopups() | m.tab is sentence],
        *[<"#grammar", popup("The current grammar is edited here. Which one is used depends on the commit and revert buttons.")> | m.tab is grammar], 
        *[<"#diagnosis", popup("A detailed story line of the diagnosis of the current sentence is told here. Read top to bottom!")> | m.tab is diagnosis],     
        *[<"#graphic", popup("We get a general feel for the differences between the alternatives in the graphical view.")> | m.tab is graphic],  
        *[<"#file-menu", popup("Use the file menu to save all your work and come back to it later, or use it in continuous testing processes.")>]     
    ];

Popups sentencePopups()
    = [
        <"#sentence-editor", popup("The current input sentence under investigation is edited here. It is the main input to the diagnosis process next to the grammar.", placement=bottom())>,
        <"#first-impressions", popup("We get a rough impression of the severity of the problem here, if any.")>,
        <"#stash-button", popup("Click this to store the current sentence, with its non-terminal, for future reference.", placement=left())>,
        <"#generate-button", popup("Random generation of ambiguous sentences for the current non-terminal.", placement=top())>,
        <"#simplify-button", popup("Random simplification, under the invariant of ambiguity.", placement=left())>,
        <"#nonterminalChoice", popup("Pick the non-terminal to apply to the current sentence here.", placement=bottom())>
    ];