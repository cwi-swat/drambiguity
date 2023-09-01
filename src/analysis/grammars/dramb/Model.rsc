module analysis::grammars::dramb::Model

import ValueIO;
import ParseTree;
import util::Maybe;

data Tab 
  = sentence()
  | graphic()
  | grammar()
  | diagnosis()
  ;

Model model(&T<:Tree input, type[Tree] grammar, Tab tab=sentence()) 
  = model(grammar, tab=tab)[tree=just(input)];

Model model(loc saved) = readBinaryValueFile(#Model, saved);

data Model 
  = model(type[Tree] grammar,
      str input = "",
      Maybe[Tree] tree = saveParse(grammar, input),
      Maybe[loc] file = just(|home:///myproject.dra|),
      str grammarText = format(grammar),
      str commitMessage = "",
      lrel[datetime stamp, str msg, str grammar] grammarHistory = [<now(), "initial", grammarText>],
      lrel[str input, Symbol nt, Maybe[Tree] tree, str status]  examples = [],
      int generationEffort = 5, 
      list[str] errors = [],
      bool labels = false, 
      bool literals = false,
      bool \layout = false,
      bool chars = true,
      Tab tab = sentence()
    );