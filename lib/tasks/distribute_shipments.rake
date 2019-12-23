require 'csv'

task :distribute_shipments => :environment do
  @trucks = parse_trucks
  @shipments = parse_shipments
  perfect_match # look for quick wins where we can maximize a truck's capacity immediately
  @trucks.each do |truck|
    next if truck_remaining_capacity(truck) == 0
    fill_capacity(truck)
  end
  puts "-"*50
  puts "Cumulative Maximum Allocation: #{add_truck_allocations}"
  puts "RAW OUTPUT | Truck Capacity Allocation..."
  puts @trucks
  puts "-"*50
  puts "Cumulative Shipments Remaining: #{add_shipments_remaining}"
  puts "RAW OUTPUT | Shipments Remaining..."
  puts @shipments
end

def parse_trucks
  trucks = CSV.read('public/trucks.csv')
  trucks.shift
  available_trucks = []
  trucks.each do |truck|
    available_trucks << {
      id: truck[0],
      current_allocation: 0,
      shipments: [],
      max_capacity: truck[1].to_i
    }
  end
  available_trucks.sort_by { |t| t[:max_capacity] }.reverse!
end


def parse_shipments
  shipments = CSV.read('public/shipments.csv')
  shipments.shift
  pending_shipments = []
  shipments.each do |shipment|
    pending_shipments << {
      id: shipment[0],
      size: shipment[1].to_i
    }
  end
  pending_shipments.sort_by { |s| s[:size] }.reverse!
end

def perfect_match
  @trucks.each do |truck|
    if perfect_match = @shipments.find { |shp| shp[:size] == truck[:max_capacity] }
      truck[:shipments] << perfect_match
      @shipments.delete(perfect_match)
      truck[:current_allocation] += perfect_match[:size]
    end
  end
end

def fill_capacity(truck)
  smallest_shipment_size = @shipments.last[:size]
  while truck_remaining_capacity(truck) > smallest_shipment_size
    shipments = @shipments.select { |shp| shp[:size] < truck_remaining_capacity(truck)} # reduce selections so we don't have to loop through as many options
    optimized = optimize_selections(truck_remaining_capacity(truck), shipments)
    optimized.each do |shipment|
      truck[:shipments] << shipment
      @shipments.delete(shipment)
      truck[:current_allocation] += shipment[:size]
    end
    smallest_shipment_size = @shipments.last[:size]
  end
end

def optimize_selections(available_capacity, shipments)
  largest_size = shipments.first[:size] # immediately identify the largest shipment closest to the available capacity, as a benchmark
  optimal = []
  perfect_combo = false
  i = 1 # start with the second shipment in the array, as the first is already a benchmark
  while i < shipments.length
    next_best_fit = shipments[i]
    shipments.each_with_index do |shipment, idx|
      next if idx <= i # prevent unnecessary looping backwards
      if (shipment[:size] + next_best_fit[:size]) > largest_size && (shipment[:size] + next_best_fit[:size]) <= available_capacity
        largest_size = shipment[:size] + next_best_fit[:size] # if pass conditionals, set a new benchmark
        optimal = []
        optimal << shipment
        optimal << next_best_fit
        perfect_combo = true if largest_size == available_capacity
        break if perfect_combo # break the loop if optimal capacity was found
      end
    end
    break if perfect_combo # break the loop if optimal capacity was found
    i += 1
  end
  optimal << shipments.first if optimal.empty?
  optimal
end

def truck_remaining_capacity(truck)
  truck[:max_capacity] - truck[:current_allocation]
end

def add_truck_allocations
  cumulative = 0
  @trucks.each do |truck|
    cumulative += truck[:current_allocation]
  end
  cumulative
end

def add_shipments_remaining
  cumulative = 0
  @shipments.each do |shipment|
    cumulative += shipment[:size]
  end
  cumulative
end
