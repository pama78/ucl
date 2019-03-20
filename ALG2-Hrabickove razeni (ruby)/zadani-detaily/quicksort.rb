class Array

  # Sorts the array using (randomized) quicksort.
  def quicksort!(left = 0, right = self.size - 1)
    if right > left
      pivot_index = left + rand(right - left + 1)
      # divide
      new_pivot_index = partition(left, right, pivot_index)
      quicksort!(left, new_pivot_index - 1)
      quicksort!(new_pivot_index + 1, right)
      # conquer
    end
    return self
  end

  private

  # In O(right - left) reorders the specified (by the indices left and right) part
  # of self, so that there are first only values less than the pivot, then there is
  # the pivot itself and then there are values greater than the pivot.
  #
  # +pivot_index+: index of the pivot
  #
  # Returns new index of the pivot (after reordering).
  def partition(left, right, pivot_index)
    pivot = self[pivot_index]
    # move pivot in the right corner
    if pivot_index != right
      x = self[pivot_index]
      self[pivot_index] = self[right]
      self[right] = x
    end
    # sweep through the array and preserve at
    # 0..(index-1) -- items <  pivot
    # index..i     -- items >= pivot
    index = left
    left.upto(right) do |i|
      if self[i] < pivot
        if i != index
          x = self[i]
          self[i] = self[index]
          self[index] = x
        end
        index += 1
      end
    end
    # put the pivot between the two parts
    if index != right
      x = self[index]
      self[index] = self[right]
      self[right] = x
    end
    # return the position of the pivot
    return index
  end

end
