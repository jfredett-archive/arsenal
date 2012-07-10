require 'rspec/expectations' 


module CustomMatchers
  class DelegateMatcher
    def initialize(message_to_receive)
      @message_to_receive = message_to_receive
    end

    def to_each
      self
    end

    def when_sent(message_to_send)
      @message_to_send = message_to_send
      self
    end

    def and_aggregate_with(aggregator)
      @aggregator = aggregator
      self
    end

    def matches?(target)
      @target = target
      return false unless target.respond_to? :each

      target.each do |e|
        if shortcircuits?(aggregator)
          e.should_receive(message_to_receive).at_most(:once)
        else
          e.should_receive(message_to_receive)
        end
      end
      target.should_receive(aggregator) if aggregator

      target.send(message_to_send)
      true
    end

    attr_reader :aggregator, :message_to_send

    def message_to_receive
      @message_to_receive || @message_to_send
    end

    def failure_message_for_should
      "#{basic_message} #{aggregator_message if aggregator}"
    end

    private

    def basic_message
      %{Expected #{@target.class} to delegate ##{message_to_receive} to each element in it when being sent ##{message_to_send}}
    end

    def aggregator_message
      %{and aggregate the results with ##{aggregator}}
    end

    def shortcircuits?(agg)
      agg == :all? or agg == :any?
    end
  end

  def delegate(message)
    DelegateMatcher.new(message)
  end
end

#RSpec::Matchers.define :delegate do |to_send|
  #match do |obj|
    #return false unless obj.respond_to? :each

    #obj.each do |e|
      #e.should_receive(to_send)
    #end

    #obj.should_receive(@aggregator) if @aggregator
    #obj.send(@to_receive)
  #end

  #chain(:to_each) { }

  #chain :when_sent do |to_receive|
    #@to_receive = to_receive
  #end

  #chain :and_aggregate_with do |aggregator|
    #@aggregator = aggregator
  #end
#end
