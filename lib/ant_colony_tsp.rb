require "ant_colony_tsp/version"

module AntColonyTsp
  class AntColonyTsp
    # distance, between cities
    def euc_2d(c1, c2)
      Math.sqrt((c1[0] - c2[0]) ** 2.0 + (c1[1] - c2[1]) ** 2.0).round
    end

    # cost, of the tour
    def cost(sh, cities)
      distance = 0
      sh.each_with_index do |c1, i|
        c2 = (i == (sh.size - 1)) ? sh[0] : sh[i + 1]
        distance += euc_2d(cities[c1], cities[c2])
      end
      distance
    end

    # shake, cities
    def shake(cities)
      sh = Array.new(cities.size){|i| i}
      sh.each_index do |i|
        r = rand(sh.size - i) + i
        sh[r], sh[i] = sh[i], sh[r]
      end
      sh
    end

    # phero matrix, get it
    def get_phero_matrix(num_cities, init_pher)
      return Array.new(num_cities){|i| Array.new(num_cities, init_pher)}
    end

    # where to go next
    def get_choices(cities, last_city, skip, pheromone, c_heur, c_hist)
      choices = []
      cities.each_with_index do |position, i|
        next if skip.include?(i)
        prob = {:city => i}
        prob[:history] = pheromone[last_city][i] ** c_hist
        prob[:distance] = euc_2d(cities[last_city], position)
        prob[:heuristic] = (1.0 / prob[:distance]) ** c_heur
        prob[:prob] = prob[:history] * prob[:heuristic]
        choices << prob
      end
      choices
    end

    # select city, next
    def select_city(choices)
      sum = choices.inject(0.0) {|sum, item| sum + item[:prob]}
      return choices[rand(choices.size)][:city] if sum == 0.0
      v = rand()
      choices.each_with_index do |choice, i|
        v -= (choice[:prob] / sum)
        return choice[:city] if v <= 0.0
      end
      return choices.last[:city]
    end

    # select city, greedy
    def select_city_greedy(choices)
      return choices.max{|a, b| a[:prob] <=> b[:prob]}[:city]
    end

    # get tour +++
    def get_tour(cities, phero, c_heur, c_greed)
      sh = []
      sh << rand(cities.size)
      begin
        choices = get_choices(cities, sh.last, sh, phero, c_heur, 1.0)
        greedy = rand() <= c_greed
        next_city = (greedy) ? select_city_greedy(choices) : select_city(choices)
        sh << next_city
      end until sh.size == cities.size
      sh
    end

    # update phero, global
    def update_phero_global(phero, candidate, decay)
      candidate[:vector].each_with_index do |row, i|
        col = (i == candidate[:vector].size - 1) ? candidate[:vector][0] : candidate[:vector][i + 1]
        value = ((1 - c_local_phero) * phero[row][col]) + (c_local_phero * init_phero)
        phero[row][col] = value
        phero[col][row] = value
      end
    end

    # update phero, local
    def update_phero_local(phero, candidate, c_local_phero, init_phero)
      candidate[:vector].each_with_index do |row, i|
        col = (i == candidate[:vector].size - 1) ? candidate[:vector][0] : candidate[:vector][i + 1]
        value = (1.0 - c_local_phero) * phero[row][col] + (c_local_phero * init_phero)
        phero[row][col] - value
        phero[col][row] = value
      end
    end

    # search
    def search(cities, max_it, num_ants, decay, c_heur, c_local_phero, c_greed)
      best = {:vector => shake(cities)}
      best[:cost] = cost(best[:vector], cities)
      init_phero = 1.0 / (cities.size.to_f * best[:cost])
      phero = get_phero_matrix(cities.size, init_phero)
      max_it.times do |iter|
        num_ants.times do
          cand = {}
          cand[:vector] = get_tour(cities, phero, c_heur, c_greed)
          cand[:cost] = cost(cand[:vector], cities)
          best = cand if cand[:cost] < best[:cost]
          update_phero_local(phero, cand, c_local_phero, init_phero)
        end
          update_phero_global(phero, cand, decay)
          puts " > iteration #{iter + 1}, best #{best[:cost]}"
      end
      best
    end
  end
end
