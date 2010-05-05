# random sampling (yer basic guesser)

GuesserWorkstation.workflow_definition do
  
  # 'to :inventory!' is missing, so execution
  # falls back to [empty] super Workstation.inventory!
  
  to :build! do
    consecutive :answers do
      # make a new answer, and merge that into @answers
      process_with my_random_sampler 
    end
  end
  
  to :ship! do
    # "sends" all answers to :next_station, saves them to the db,
    # and removes them immediately from @answers
    ship_to :next_station => Proc{|answer| true} 
  end
  
  to :scrap! do
    # just in case?
    # "sends" all remaining answers to :scrapheap, saves them to the db
    scrap_everything
  end
end


# population GA workstation, receiving answers from upstream (somewhere)

PopGAWorkstation.workflow_definition do
  to :inventory! do
    consecutive :answers do
      gather Proc{|a| a.locations.include? @name} 
      gather Proc{...} # a.locations.overlaps @collaborator.names
    end
  end
  
  to :build! do
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
  to :ship! do
  emd
  
  to :scrap! do
    @highest_progress = (@answers.collect {|a| a.progress}).max
    
    # 'scrap' filters all @answers, changing location, saving and
    # removing them immediately from @answers
    scrap "too_old" => Proc{|a| a.progress < @highest_progress} 
  end
end



# random hillclimbing workstation, with random guessing if needed

HillclimberWorkstation.workflow_definition do

  to :inventory! do
    gather_into :answers => Proc{|a| a.locations.include? @name} 
  end
  
  to :build! do
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
  
  to :ship! do
    @highest_progress = (@answers.collect {|a| a.progress}).max
    # "sends" those, saves them, and removes immediately from @answers [if true]
    ship_to :next_station => Proc{|a| a.progress == @highest_progress} 
  end
  
  to :scrap! do
    scrap_everything # "sends" anything left to location "scrapheap"
  end
end



# "polisher" that applies particle swarm search to one nondominated 
# answer in its inventory, throwing away all intermediate
# results, and shipping off the nondominated one(s)

Polisher.workflow_definition do
  
  to :inventory! do
    # there may be 0 or more
    gather_into :answers => Proc{|a| a.locations.include? @name}
  end
  
  to :build! do
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
  
  to :ship! do
    ship_to :next_station => Proc{|answer| answer.tags.include? "ship_A_to_B"}
  end
  
  # we're not scrapping anything
  # we've just shipped off the best, and will maybe receive more work later
  # meanwhile, we keep polishing what we've got
  to :scrap! do
  end
end



# coevolutionary evaluator workstation:
# uses two populations, one of answers and one of "test suites".
# Both groups are evaluated at the same time.

TwoSpeciesCompetitiveEvaluator.workflow_definition do
  
  to :inventory! do
    
    # Note that this factory should deal with different
    #"species" more cleanly than this code implies!
    
    gather_into :answers => Proc{|a| (a.locations.include? @name) && !(a.tags.include? "trainer")}
    gather_into :trainers => Proc{|a| (a.locations.include? @name) && (a.tags.include? "trainer")}
  end
  
  to :build! do
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
  
  to :ship! do
    ship_to :where_answers_go => Proc{|answer| answer.tags.!include? "trainer"}
    ship_to :where_trainers_go => Proc{|answer| answer.tags.include? "trainer"}
  end
  
  to :scrap! do
    # nothing should be left
  end
end
