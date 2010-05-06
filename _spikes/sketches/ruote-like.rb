# random sampling (yer basic guesser)

class GuesserWorkstation << Workstation
  
  # 'def receive!' is missing, so execution
  # falls back to super
  
  
  def :build!
    consecutive :answers do
      # make a new answer, and merge that into @answers
      process_with my_random_sampler 
    end
  end
  
  
  def :ship!
    # "sends" all answers to :next_station, saves them to the db,
    # and removes them immediately from @answers
    ship_to(:next_station) {|answer| true} 
  end
  
  
  def :scrap!
    # just in case?
    # "sends" all remaining answers to :scrapheap, saves them to the db
    scrap_everything
  end
end


# population GA workstation, receiving answers from upstream (somewhere)

class PopGAWorkstation < Workstation
  def :receive!
    gather_mine # returns all answers with self.name in #tags
    
    self.collaborator_names.each do |neighbor|
      gather_into("collaborators") {|a| a.tags.include?(neighbor.to_s)}
    end
  end
  
  
  def :build!
    channel :answers do
      # generate (increment progress), and pass into next line
      process_with my_crossover_operator_instance 
      
      # generate (increment progress), and pass into next line
      process_with my_mutation_operator_instance 
      
      # no progress change, just scores
      process_with my_evaluator_instance
      
      # results merged back into @answers now
    end
  end
  
  
  # nothing to ship; this is the end of a line
  def :ship!
  emd
  
  
  def :scrap!
    @highest_progress = (@answers.collect {|a| a.progress}).max
    
    # 'scrap' filters all @answers, changing location, saving and
    # removing them immediately from @answers
    scrap_if("too_old") {|a| a.progress < @highest_progress} 
  end
end



# random hillclimbing workstation, with random guessing if needed

class HillclimberWorkstation < Workstation
  
  def :receive!
    gather_mine 
  end
  
  
  def :build!
    # if there are none, create one
    if @answers.empty?
      consecutive :answers do
        # make a new answer, and merge that into @answers
        process_with my_random_sampler 
      end
    end
    
    100.times do
      channel :answers do
        # generate and pass into next line
        process_with my_mutation_operator_instance 
        # update scores
        process_with my_evaluator_instance 
        # returns only the (internally) nondominated subset of those
        process_with my_nondominated_filter 
      end
    end
  end
  
  
  def :ship!
    @highest_progress = (@answers.collect {|a| a.progress}).max
    
    # "sends" those, saves them, and removes immediately from @answers [if true]
    ship_to(:next_station) {|a| a.progress == @highest_progress} 
  end
  
  
  def :scrap!
    scrap_everything # "sends" anything left to location "scrapheap"
  end
end



# "polisher" that applies particle swarm search to one nondominated 
# answer in its receive, throwing away all intermediate
# results, and shipping off the nondominated one(s)

class Polisher < Workstation
  
  def :receive!
    gather_mine
  end
  
  
  def :build!
    # we start from @answers but do not merge results until
    # the end of this block:
    channel :answers do
      
      # pick the "best" answer (may be several)
      process_with my_nondominated_filter
      
      # pick one of those at random
      process_with my_random_sampler
            
      # entering a consecutive block with @work_in_process
      consecutive :work_in_process do 
        
        # makes a bunch of random variants of the values
        # we're in a "consecutive" block,
        # so these are returned to the surrounding Batch: @work_in_process
        process_with my_swarm_value_randomizer
        
        # applied to all of @work_in_process:
        process_with my_evaluator
      end
      
      # set up swarm memory
      # TBD
      
      # 20.fold:
      # TBD ('fold' makes a channel that loops N times, re-running its code on its own results)
        # 1. random perturbation of all swarm members' velocity
        # 2. shift all swarm members' velocities towards best_ever
        # 3. shift all swarm members/ velocities towards their personal bests
        # 4. move all members
      
      # select only nondominated subset
      # because this is all one channel block,
      # that's what's returned to the @answers
    end
    
    # label the overall nondominated set for shipping
    
    channel :answers do
      process_with my_nondominated_filter
      
      # mark all the results of the preceding with "ship_A_to_B"
      process_with my_shipping_labeler
    end
  end
  
  
  def :ship!
    ship_to(:next_station) {|answer| answer.tags.include? "ship_A_to_B"}
  end
  
  
  # we're not scrapping anything
  # we've just shipped off the best, and will maybe receive more work later
  # meanwhile, we keep polishing what we've got
  def :scrap!
  end
end



# coevolutionary evaluator workstation:
# uses two populations, one of answers and one of "test suites".
# Both groups are evaluated at the same time.

class TwoSpeciesCompetitiveEvaluator < Workstation
  
  def :receive!
    # Note that this factory should deal with different
    #"species" more cleanly than this code implies!
    
    gather_into(:answers) {|a| (a.locations.include? @name) && !(a.tags.include? "trainer")}
    gather_into(:trainers) {|a| (a.locations.include? @name) && (a.tags.include? "trainer")}
  end
  
  
  def :build!
    consecutive :answers do
      # perhaps the trainers here are linear genomes only, with just integer values
      # and they're used to select training cases from a large
      # list of examples in a database
      
      # the score of each answer is determined by picking five trainers (at random)
      # and playing a game; the score of each trainer is determined by
      # the negative average score of all the answers it trains
      
      # since we're just updating scores, we can iterate over @answers:
      @answers.each do |answer|
        @training_round = Batch.new[answer, @trainers.sample(5)]
        consecutive :training_round do
          process_with my_coevolutionary_evaluator
          
          # updates the score of this answer;
          # modifies the score of each trainer, and
          # does the bookkeeping internally to do the averaging
        end
      end
      
      # every answer has played against five trainers;
      # answer scores are recorded; 
      # trainers' scores have been updated, too
    end
  end
  
  
  def :ship!
    ship_to(:where_answers_go) {|answer| answer.tags.!include? "trainer"}
    ship_to(:where_trainers_go) {|answer| answer.tags.include? "trainer"}
  end
  
  
  def :scrap!
    # nothing should be left
  end
end
