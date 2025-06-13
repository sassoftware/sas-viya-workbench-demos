filename inpipe pipe "unzip -p /workspaces/myfolder/data/higgs.zip | gunzip -c";

%let varnames = signal lepton_pt lepton_eta lepton_phi 
                missing_energy_magnitude missing_energy_phi
                jet_1_pt jet_1_eta jet_1_phi jet_1_btag
                jet_2_pt jet_2_eta jet_2_phi jet_2_btag
                jet_3_pt jet_3_eta jet_3_phi jet_3_btag
                jet_4_pt jet_4_eta jet_4_phi jet_4_btag
                m_jj m_jjj m_lv m_jlv m_bb m_wbb m_wwbb
                ;

data higgs;
    infile inpipe dsd dlm=',';
    input &varnames;
run;

proc gradboost data=higgs outmodel=low_level_model seed=42 ;
    partition fraction(validate=0.15 test=0.15 seed=42);
    target signal / level=nominal;
    input lepton_pt--jet_4_btag;
    output out=low_level_preds role;
run;

proc gradboost data=higgs outmodel=high_level_model seed=42;
    partition fraction(validate=0.15 test=0.15 seed=42);
    target signal / level=nominal;
    input m_jj--m_wwbb;
    output out=high_level_preds role;
run;

/* 
proc gradboost data=higgs outmodel=low_level_model seed=42;
    partition fraction(validate=0.15 test=0.15 seed=42);
    autotune objective=auc searchmethod=bayesian maxiter=30;
    target signal / level=nominal;
    input lepton_pt--jet_4_btag;
    output out=low_level_preds role;
run;
*/