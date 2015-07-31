module QQ
  class JobList
    def initialize(jobs = [])
      if jobs.is_a? String
        jobs = Parser.from_string(jobs)
      end

      # TODO: Add fail-safe for symbols.

      @jobs = generate_jobs(jobs)

      # Cleanup/refactor
      ensure_no_self_dependencies
      ensure_no_unknown_dependencies      
    end

    def <<(job)
      @jobs << job
    end

    # Find a Job in the JobList with the passed ID.
    def find_by_id(id)
      @jobs.find { |job| job.id == id }
    end

    # Returns true/false depending on if the JobList contains a Job with the ID.
    def include?(id)
      !!find_by_id(id)
    end

    # Creates a TSortableHash for all of the jobs and dependencies and returns
    # the TSorted array
    def tsort_ids
      begin
        @jobs.each_with_object(unsorted = TSortableHash.new(0)) do |job, hash|
          hash[job.id] = job.dependencies
        end

        unsorted.tsort
      rescue TSort::Cyclic => e
        fail CyclicDependencyError, 
          "Jobs cannot have Circular dependencies: #{e}."
      end
    end

    # Takes a TSorted array and replaces the IDs with Job instances from @jobs.
    def tsort
      tsort_ids.each_with_object([]) do |id, arr|
        arr << find_by_id(id)
      end
    end

    # Permanently TSorts the jobs array
    def tsort!
      @jobs = tsort
    end

    def length
      @jobs.length
    end

    def select(*args, &block)
      @jobs.select(*args, &block)
    end

    def to_a
      @jobs
    end

    private

    # Create Job instances for each of the jobs.
    def generate_jobs(jobs)
      jobs.each_with_object([]) do |(id, dependencies), jobs|
        # Allow Job objects and Arrays to be interchanged.
        if id.is_a? Job
          jobs << id
        else
          jobs << Job.new(id, dependencies)
        end
      end
    end

    # Fail on any self-depenent jobs
    def ensure_no_self_dependencies
      self_dependents = @jobs.select(&:has_self_dependency?)

      unless self_dependents.empty?
        fail SelfDependencyError, 
          "Jobs can't depend upon themselves.\n\t#{self_dependents}\n\n"
      end
    end

    # Fail if any job depends on a non-existent job.
    def ensure_no_unknown_dependencies
      deps = @jobs.map(&:dependencies).flatten
      jobs = @jobs.map(&:id).flatten
      offending_jobs = deps.reject {|id| jobs.include? id}

      unless offending_jobs.empty?
        fail NonExistentDependencyError, 
          "Jobs can only depend on jobs that exist.\n\t#{offending_jobs}\n\n"
      end
    end
  end
end
