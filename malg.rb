class Malg

  # class Graph
  #   attr_accessor :graph, :sources
  #   def initialize
  #     @graph = { 'schools' => [], 'departments' => [], 'courses' => [], 'sections' => [] }
  #     @sources {}
  #   end

  #   def add_record type, record, source
  #     @graph[]
  #   end
  # end
  

  DATA_TYPES = %w(schools departments courses sections).freeze
  DATA_TYPE_UIDS = { 'schools' => 'name', 'departments' => 'code', 'courses' => 'number', 'sections' => 'name' }.freeze

  def initialize priorities
    @priorities = priorities
    @graph = { 'schools' => [], 'departments' => [], 'courses' => [], 'sections' => [] }
    @sources = {}
  end

  def can_build_graph?
    priorities.vital_sources_ready?
  end

  def add_record record, type, source, parent
    throw 'Nil Parent Error' if parent == nil && type != 'schools'
    new_record = record.clone
    @graph[type] << new_record
    if parent
      parent[type] ||= []
      parent[type] << new_record
    end
    @souces[new_record.object_id] = new_record.transform_values { |v| source }
    new_record
  end

  def ammend_record old_record, new_record, type, new_source
    new_record.reject{ |k, v| DATA_TYPES.any? k }.each do |k, v|
      if priorities.get(type, k, new_source) > priorities.get(type, k, @sources[old_record.object_id])
        old_record[k] = v
        @sources[old_record.object_id][k] = new_source
      end
    end
    old_record
  end

  def find_matching_record record, type, collection
    return nil unless collection
    collection.detect do |collection_record|
      collection_record[DATA_TYPE_UIDS[type]] == record[DATA_TYPE_UIDS[type]]
    end
  end

  def handle_record record, type, source, parent
    if parent
      old_record = find_matching_record record, type, parent[type]
      if old_record
        return ammend_record old_record, record, type, source.name
      else
        return add_record record, type, source.name, parent
      end
    else
      old_record = find_matching_record record, type, @graph[type]
      if old_record
        return ammend_record old_record, record, type, source.name
      else
        puts "Error: Unresolvable #{type} #{record} from source #{source.name}"
      end
    end
  end

  def handle_collection collection, type, source, parent
    collection.map do |source_record|
      record = handle_record source_record, type, source, parent
      child_type = @schema.child_type_for type
      if child_type && source_record[child_type]
        handle_collection source_record[child_type], child_type, source, record
      end
      record
    end
  end

  # def process_sections sections, course, source
  #   sections.each do |ss|
  #     if course
  #       section = course['sectios'] && course['sections'].detect { |gs| gs['name'] == ss['name'] }
  #       if section
  #         ammend_record section, ss, 'sections', source.name
  #       else
  #         add_record ss, 'sections', source.name, course
  #       end
  #     else
  #       section = @graph['sections'].detect { |gs| gs['name'] == ss['name'] }
  #       if section
  #         ammend_record section, ss, 'sections', source.name
  #       else
  #         puts "Error: Unresolvable section #{ss} from source #{source.name}"
  #       end
  #     end
  #   end
  # end
  

  def update_from_source source
    type = source.root_type
    handle_collection source.data[source.root_type], source, nil
  end

  def initialize_graph
    throw 'Necessary Sources Missing' unless can_build_graph?

    priorities.sources_by_hierarchy.each do |source|
      update_from_source source
    end
  end

  def build_graph

    # throw 'Necessary Sources Missing' unless can_build_graph?
    
    default_order = sources.sort { |a, b| priorities.default(a) <=> priorities.default(b) }

    processed_sources = []

    default_order.filter { |s| s.data['schools'] }.each do |source|
      processed_sources << source.name

      source.data['schools'].each do |ss|
        school = @graph['schools'].detect { |gs| gs['name'] == ss['name'] }

        if school
          school['departments'] ||= []
          ss['departments'] ||= []
          ss['departments'].each do |sd|
            department = school['departments'].detect { |gd| gd['code'] == sd['code'] }

            if department
              department['courses'] ||= []
              sd['courses'] ||= []
              sd['courses'].each do |sc|
                course = department['courses'].detect { |gc| gc['number'] == sc['number'] }
                course = handle_record sc, 'courses', source, department

                if course
                  ammend_record course, sc, 'courses', source.name
                  if sc['sections']
                    sc['sections'].each { |section| handle_record section, 'sections', source, course }
                    # course['sections'] ||= []
                    # process_sections sc['sections'], course, source

                  # sc['sections'] ||= []
                  # sc['sections'].each do |ss|
                  #   section = course['sections'].detect { |gs| gs['name'] == ss['name'] }

                  #   if section
                  #     ammend_record section, ss, 'sections', source.name
                  #   else
                  #     add_record ss, 'sections', source.name, course
                  #   end
                  end
                else
                  add_record sc, 'courses', source.name, department
                end
              end
            else
              add_record sd, 'departments', source.name, school
            end
          end
        else
          add_record ss, 'schools', source.name, nil
        end
      end
    end
  end






  #    # graph['schools'] ||= source.data['schools']
  #         # school['departments'] = (school['departments'] || []) | (ss['departments'] || [])
  #         # 
  #   for 

  #   sources.sort(&:priority).each do |source|

  #   end



  #   graph = { 'schools' => {}, 'departments' => {}, 'courses' => {}, 'sections' => {} }

  #   for

  # end

  def pull_schools source

  end

  def update data

  end
end