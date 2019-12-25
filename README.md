# BIN PACKING ALGORITHM
---

## The Goal

Given a number of trucks, each with differing available capacity, let's write an algorithm to distribute a number of shipments, each with differing sizes, trying to ship all goods and minimize wasted space.

## Considerations

**The Data**
The data in this problem is found in some CSV files found in the public directory. The cumulative capacity of the shipments is greater than the cumulative capacity of the trucks. We also assume we cannot break apart shipments into more granular sizes. It's all or nothing with each shipment.

**Controlled Scenario**
This toy problem is controlled, leaving off a variety of possible variables to consider in the real world. For instance, where is each shipment's destination? We assume they're all being shipping to the same location in this example. What about freight costs and the nature of the goods themselves. Perhaps there are some more sensitive goods that require cross border inspection by the FDA or other government agencies. Does that change how we want to package shipments together?

**One Dimensional**
We have only a single dimension measurement in this problem. A general unit we can refer to as size or capacity. In the real world, we would likely have many dimensions to consider. Square footage, weight, solvency, temperature, etc.

## Solution

Given all the considerations above, the first thing we want to do is parse the raw data from the CSV files and turn them into sorted arrays by size / capacity. We sort descending, with the largest shipments and trucks first so that we can ensure the largest shipments are accounted. The largest shipments have less flexibility as its a all or nothing scenario, so we want to handle those before we start to allocate more granular shipments. Each array of shipments and trucks is an array of objects so that we can track a variety of information as we travel through the algorithm.

Next, we look to see if any shipments are a perfect match with any truck, where the shipment size == the truck capacity. If we do find that, we can immediately allocate that shipment and save ourselves from having to loop through a truck.

Once all perfect matches have been explored, we move on to looping through the remaining trucks with the `fill_capacity` method. This method along with the `optimize_selections` method assembles the best combination of shipments for each truck, given it's capacity limitation. This is done through a series of loops, where we examine and compare solutions against each other through each cycle. Once the ideal solution has been found, we update our instance variables, removing the shipments remaining from `@shipments` and subsequently updating the `@trucks` variable, specifically each truck's `current_allocation` and `shipments` key value pairs. We do this with the `perform_allocation` method.

## ENV Setup / Run Instructions

- Rails 6.0.2.1
- Ruby 2.6.5
- Node + NPM + Yarn required for Webpack (comes preloaded with Rails 6)

Run the rake task: `rake distribute_shipments`

**OUTPUT**
The rake task will output the following in your shell:

```
Cumulative Maximum Allocation: 126200
RAW OUTPUT | Truck Capacity Allocation...
{:id=>"001", :current_allocation=>44000, :shipments=>[{:id=>"001", :size=>16000}, {:id=>"010", :size=>28000}], :max_capacity=>44000}
{:id=>"002", :current_allocation=>42000, :shipments=>[{:id=>"002", :size=>42000}], :max_capacity=>42000}
{:id=>"004", :current_allocation=>22200, :shipments=>[{:id=>"003", :size=>8000}, {:id=>"004", :size=>12000}, {:id=>"006", :size=>1200}, {:id=>"007", :size=>1000}], :max_capacity=>24000}
{:id=>"003", :current_allocation=>18000, :shipments=>[{:id=>"009", :size=>18000}], :max_capacity=>20000}
--------------------------------------------------
Cumulative Shipments Remaining: 99500
RAW OUTPUT | Shipments Remaining...
{:id=>"005", :size=>38000}
{:id=>"013", :size=>37000}
{:id=>"012", :size=>17000}
{:id=>"011", :size=>7500}
```

## Limitations

This algorithm plays on the assumptions and considerations mentioned above. It also doesn't attempt to add more than 2 shipments together at any given time, to try and find the optimal combination... instead electing to loop through remaining shipments if a truck's capacity is not full and there is still at least one shipment that could fit. We also don't have any persisted combinations in a database that could possibly speed up optimization discovery for a specific truck.
