class SkiPathPlanner
    attr_reader :nRow, :nCol, :skiMap

    def initialize()
        @nRow = 0
        @nCol = 0
        @skiMap = nil
    end

    def LoadMap(inputFile)
        print "LoadMap\n"

        # skiMap contains map data
        @skiMap = Array.new
        File.foreach(inputFile).with_index do |line, index|
            elem = line.split.map(&:to_i)
            if (index == 0)
                @nRow = elem[0]
                @nCol = elem[1]
            else
                @skiMap.push(elem)
            end
        end
    end

    def FindLongestPath()

        topoOrder = self.TopologicalSort()

        print "FindLongestPath\n"

        # bestPath contains the best path for each node
        bestPath = Array.new(self.nRow){Array.new(self.nCol)}

        # directions to 4 adjacent nodes
        dx = [0, 0, -1, 1]
        dy = [-1, 1, 0, 0]

        # for each node following the order of topological sort
        topoOrder.each do |coord|
            x = coord[0]
            y = coord[1]

            # bestScore is used to save the best candidate within adjacent nodes
            bestScore = nil
            (0..3).each do |d|
                adjX = x + dx[d]
                adjY = y + dy[d]

                # to not go out of the map
                if (adjX < 0 || adjY < 0 || adjX >= self.nRow || adjY >= self.nCol)
                    next
                end

                # check if we can ski from (adjX, adjY) to (x, y)
                if (self.skiMap[adjX][adjY] > self.skiMap[x][y])
                    len = bestPath[adjX][adjY].len
                    diff = bestPath[adjX][adjY].diff

                    # build new score
                    newScore = PathScore.new(len + 1, diff + self.skiMap[adjX][adjY] - self.skiMap[x][y])

                    # update best score
                    if (bestScore.nil? || bestScore < newScore)
                        bestScore = newScore
                    end
                end
            end

            # update to bestPath array
            if (bestScore.nil?)
                bestPath[x][y] = PathScore.new(1, 0)
            else
                bestPath[x][y] = bestScore
            end
        end

        # get best result
        result = nil
        (0..self.nRow - 1).each do |r|
            (0..self.nCol - 1).each do |c|
                if (result.nil? || result < bestPath[r][c])
                    result = bestPath[r][c]
                end
            end
        end

        print "result = #{result.inspect}\n"
    end

    def TopologicalSort()
        print "TopologicalSort\n"

        start = Time.now
        # build a list of all pair (r, c) representing all locations in the map
        topoOrder = Array.new
        (0..self.nRow - 1).each do |r|
            (0..self.nCol - 1).each do |c|
                topoOrder.push([r, c])
            end
        end

        # sort decreasingly all nodes (r, c) by their values
        topoOrder.sort_by! { |e| -self.skiMap[e[0]][e[1]] }

        finish = Time.now
        puts "Sorting time: #{finish - start}"
        topoOrder.each do |e|
          puts self.skiMap[e[0]][e[1]]
        end
        return topoOrder
    end

    # use to path comparison
    class PathScore
        include Comparable
        attr_accessor :len, :diff

        def initialize(len, diff)
            @len = len
            @diff = diff
        end

        def <=>(anotherScore)
            if (self.len != anotherScore.len)
                if (self.len < anotherScore.len)
                    return -1
                else
                    return 1
                end
            elsif (self.diff < anotherScore.diff)
                return -1
            elsif (self.diff > anotherScore.diff)
                return 1
            else
                return 0
            end
        end

        def clone()
            inst = PathScore.new(self.len, self.diff)
            return inst
        end
    end
end

$planner = SkiPathPlanner.new
$planner.LoadMap("input_2.txt")
$planner.FindLongestPath()
