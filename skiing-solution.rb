class Elevation
  attr_accessor :coor_r, :coor_c, :parent, :value, :weight, :root, :length_to_root

  def initialize(coor_r, coor_c, value)
    @coor_r = coor_r
    @coor_c = coor_c
    @value = value
    @parent = nil
    @root = nil
    @length_to_root = 0
    @weight = 1
  end
end

class Skii
  def initialize
    @input_arr = Array.new
    @sorted_arr = Array.new
    @weightest_elevation = nil
  end

  def load_input(file_name)
    File.foreach(file_name).with_index do |line, index|
      arr = line.split.map(&:to_i)
      if index == 0
        @arr_row = arr[0]
        @arr_column = arr[1]
      else
        @input_arr.push(arr)
      end
    end
  end

  def sort_array
    (0..@arr_row - 1).each do |r|
      (0..@arr_column - 1).each do |c|
        @sorted_arr.push([r, c])
      end
    end
    # sort index array by decreasing value of input array
    @sorted_arr.sort_by! {|e| -@input_arr[e[0]][e[1]]}
  end

  def find_path
    start = Time.now
    dr = [0, 0, -1, 1]
    dc = [-1, 1, 0, 0]
    track_arr = Array.new(@arr_row){Array.new(@arr_column)}

    @sorted_arr.each do |coord|
      r = coord[0]
      c = coord[1]
      elevation = Elevation.new(r, c, @input_arr[r][c])
      weightest_elevation = weightest_elevation_around(elevation, track_arr, dr, dc)
      elevation.parent = weightest_elevation
      unless weightest_elevation.nil?
        elevation.weight = weightest_elevation.weight + 1
        elevation.root = weightest_elevation.root
      else
        elevation.root = elevation
      end
      elevation.length_to_root = elevation.root.value - elevation.value
      track_arr[r][c] = elevation
      update_key_weightest(elevation, track_arr)
    end
    finish = Time.now
    puts "Finding time: #{finish - start}"
  end

  def update_key_weightest(elevation, track_arr)
    if (@weightest_elevation.nil? ||
        elevation.weight > @weightest_elevation.weight ||
        (elevation.weight == @weightest_elevation.weight &&
          elevation.length_to_root > @weightest_elevation.length_to_root))
      @weightest_elevation = elevation
    end
  end

  def weightest_elevation_around(elevation, track_arr, dr, dc)
    weightest_elevation = nil
    (0..3).each do |num|
      adj_r = elevation.coor_r + dr[num]
      adj_c = elevation.coor_c + dc[num]

      # next if coordinates out of map size
      if (adj_r < 0 || adj_c < 0 || adj_r >= @arr_row || adj_c >= @arr_column)
        next
      end

      if (@input_arr[elevation.coor_r][elevation.coor_c] < @input_arr[adj_r][adj_c])
        adjacent = track_arr[adj_r][adj_c]
        if (weightest_elevation.nil?) ||
          (weightest_elevation.weight < adjacent.weight) ||
          (weightest_elevation.weight == adjacent.weight && weightest_elevation.value < adjacent.value)
          weightest_elevation = adjacent
        end
      end
    end
    weightest_elevation
  end

  def run
    sort_array()
    find_path()
    print_result()
  end

  private
    def print_result
      path = ""
      start_elevation = @weightest_elevation
      length = 0
      while start_elevation != nil do
        length = length + 1
        path.prepend("#{start_elevation.value} ")
        start_elevation = start_elevation.parent
      end

      puts "Length: #{length}"
      puts "Drop: #{@weightest_elevation.length_to_root}"
      puts "Path: #{path}"
    end
end

skii = Skii.new
skii.load_input("input.txt")
skii.run
