#screen
#build
#score

# DONE:

BuildRandom.build(how_many:1, code_generation_overrides:{})
SampleAnyOne.screen(batch)
RemoveAnyOne.screen(batch)

# NEXT:

SelectNondominated.screen(batch, criteria:all_shared_scores)

CrossoverPairsAtOneRandomPoint.build(
  batch, 
  how_many:default, 
  matching:pairwise, 
  overflow:cycle
  )

VaryFootnotesUniformly.build(...)


# POSSIBLE:

SampleUniform.screen(batch, prob:0.5)
RemoveUniform.screen(batch, prob:0.5)
ResampleUniform.build(batch, prob:0.5)

DuplicateAll.build(batch)

SampleByRelativeScore.screen(batch, how_many:1, criteria:all_shared_scores, decay_constant:0.5)
RemoveByRelativeScore.screen(batch, how_many:1, criteria:all_shared_scores)
ResampleByRelativeScore.build(batch, how_many:1, criteria:all_shared_scores)
# sort into domination layers
# each domination layer is :decay_constant times less likely to be selected
# sample uniformly within each domination layer

SampleByDominationTournament.screen(batch, how_many:?, tournament_size: 2, criteria:all_shared_scores)
RemoveByDominationTournament.screen(batch, how_many:?, tournament_size: 2, criteria:all_shared_scores)
SelectByDominationTournament.screen(batch, how_many:?, tournament_size: 2, criteria:all_shared_scores)

SelectDuplicates.screen(batch) # only those with identical blueprints
RemoveDuplicates.screen(batch) # removing any with identical blueprints

RemoveNondominated.screen(batch, criteria:all_shared_scores)

SelectDominationLayer.screen(batch, criteria:all_shared_scores, layer:0)
RemoveDominationLayer.screen(batch, criteria:all_shared_scores, layer:0)

SelectBestQuantile.screen(batch, criteria:all_shared_scores)
RemoveBestQuantile.screen(batch, criteria:all_shared_scores)

EvaluateOneScore.score(batch)

VaryCodeblockAtOnePoint.build(
  batch, 
  how_many:default, 
  matching:pairwise, 
  overflow:cycle,
  code_generation_overrides:{}
  )

VaryCodeblockUniformly.build(
  batch, 
  how_many:default, 
  matching:pairwise, 
  overflow:cycle,
  code_generation_overrides:{}
  )

VaryFootnotesAtOnePoint.build(batch, how_many:1)

