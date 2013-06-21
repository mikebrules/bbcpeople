class Juicer

  class << self

    # Takes a name and returns a person object for the person with that name
    def person_by_name(name)
      response = HTTParty.get(URI.encode("http://triplestore.bbcnewslabs.co.uk/api/concepts?uri=http://dbpedia.org/resource/#{name}&limit=20"))
      json_data = JSON.parse(response.body)

      Person.new(name:        json_data['label'],
                 description: json_data['abstract'],
                 dbpedia_uri: json_data['uri'],
                 image_uri:   json_data['thumbnail'])
    end

    # Takes a name and returns an organisation object for the organisation with that name
    def organisation_by_name(name)
      response = HTTParty.get(URI.encode("http://triplestore.bbcnewslabs.co.uk/api/concepts?uri=http://dbpedia.org/resource/#{name}&limit=20"))
      json_data = JSON.parse(response.body)

      Organisation.new(name:        json_data['label'],
                       description: json_data['abstract'],
                       dbpedia_uri: json_data['uri'])
    end


    # Takes an entity object and returns an array of news articles relating to that entity
    def articles_related_to(entity)
      response = HTTParty.get(URI.encode("http://triplestore.bbcnewslabs.co.uk/api/concepts?uri=#{entity.dbpedia_uri}&limit=20"))
      json_data = JSON.parse(response.body)

      return [] unless json_data['articles']

      json_data['articles'].take(20).map do |json|
        Article.new(
          cps_id:    json['cpsid'],
          headline:  json['title'],
          uri:       json['article'],
          published_at: json['published']
        )
      end
    end

    def people_related_to(entity)
      response = HTTParty.get(URI.encode("http://triplestore.bbcnewslabs.co.uk/api/concepts/co-occurrences?concept=#{entity.dbpedia_uri}&type=http://dbpedia.org/ontology/Person&limit=9"))
      json_data = JSON.parse(response.body)

      json_data['co-occurrences'].map do |json|

        if entity.name == json['label']
          nil
        else
          Person.new(
            name:              json['label'],
            cooccurence_count: json['occurrence'],
            dbpedia_uri:       json['thing'],
            image_uri:         json['img']
          )
        end
      end.compact
    end

    def organisations_related_to(entity)
      response = HTTParty.get(URI.encode("http://triplestore.bbcnewslabs.co.uk/api/concepts/co-occurrences?concept=#{entity.dbpedia_uri}&type=http://dbpedia.org/ontology/Organisation&limit=9"))
      json_data = JSON.parse(response.body)

      json_data['co-occurrences'].map do |json|
        Organisation.new(
          name:              json['label'],
          cooccurence_count: json['occurrence'],
          dbpedia_uri:       json['thing'],
          image_uri:         json['img']
        )
      end
    end
  end
end