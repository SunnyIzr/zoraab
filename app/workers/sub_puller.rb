class SubPuller
  @queue = :sub_queue
  def self.perform
    upcoming = Sub.due
    DataSession.create(data: upcoming)
  end
end
