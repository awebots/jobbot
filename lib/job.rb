class Job
  def initialize (origin, id, title, description, created_at, link)
    @origin = origin
    @id = id
    @title = title
    @description = description
    @created_at = created_at
    @link = link
  end
  attr_reader :origin, :id, :description, :created_at
  def format format
    formatted =''
    if format.include?"created_at"
      formatted += "Date: " + @created_at + "\t"
    end
    if format.include?"id"
      formatted += "id: " + @id + "\n"
    end
    if format.include?"link"
      formatted += "Link: " + @link + "\n"
    end
    if format.include?"title"
      formatted += "Title: " + @title + "\n"
    end
    if format.include?"description"
      formatted += "Text: " + @description
    end
    formatted
  end
end