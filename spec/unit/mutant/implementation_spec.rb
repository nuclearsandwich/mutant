require 'spec_helper'

module Mutant
  describe Implementation do
    def self.setup_thing(&block)
      before do
        Object.const_set(:Thing, Class.new)
        Object.const_get(:Thing).class_eval(&block) if block
      end

      after do
        Object.send(:remove_const, :Thing) if Object.const_defined?(:Thing)
      end
    end

    describe '#scope_type' do
      context 'given "Thing.alive?"' do
        it 'returns :singleton' do
          Implementation.new('Thing.alive?').scope_type.should eq(:singleton)
        end
      end

      context 'given "Thing#alive?"' do
        it 'returns :instance' do
          Implementation.new('Thing#alive?').scope_type.should eq(:instance)
        end
      end
    end

    describe '#class_name' do
      context 'given "Thing"' do
        it 'returns "Thing"' do
          Implementation.new('Thing').class_name.should eq('Thing')
        end
      end
      
      context 'given "Thing.alive?"' do
        it 'returns "Thing"' do
          Implementation.new('Thing.alive?').class_name.should eq('Thing')
        end
      end
    end

    describe '#method_scope' do
      context 'given "Thing"' do
        it 'returns nil' do
          Implementation.new('Thing').method_scope.should be_nil
        end
      end

      context 'given "Thing.alive?"' do
        it 'returns "."' do
          Implementation.new('Thing.alive?').method_scope.should eq('.')
        end
      end

      context 'given "Thing#alive?"' do
        it 'returns "#"' do
          Implementation.new('Thing#alive?').method_scope.should eq('#')
        end
      end
    end

    describe '#method_name' do
      context 'given "Thing"' do
        it 'returns nil' do
          Implementation.new('Thing').method_name.should be_nil
        end
      end

      context 'given "Thing.alive?"' do
        it 'returns "alive?"' do
          Implementation.new('Thing.alive?').method_name.should eq('alive?')
        end
      end

      context 'given "Thing#alive?"' do
        it 'returns "alive?"' do
          Implementation.new('Thing#alive?').method_name.should eq('alive?')
        end
      end
    end

    describe '#constant' do
      context 'given "Thing"' do
        setup_thing

        let(:implementation) { Implementation.new('Thing') }

        it 'returns Thing' do
          implementation.constant.should eq(Thing)
        end
      end
    end

    describe '#all_implementations' do
      let(:implementation) { Implementation.allocate }

      before do
        implementation.should_receive(:all_methods) { ['Thing.alive?'] }
      end

      let(:all_implementations) { implementation.all_implementations }

      it 'returns an array of Implementation instances' do
        all_implementations.should have(1).implementation 
        all_implementations.first.should be_a(Implementation)
      end
    end

    describe '#all_methods' do
      let(:implementation) { Implementation.allocate }

      before do
        implementation.stub(
          :all_singleton_methods => [:a], :all_instance_methods => [:b]
        )
      end

      it 'concatenates #all_singleton_methods and #all_instance_methods' do
        implementation.all_methods.should eq([:a, :b])        
      end
    end

    describe '#all_singleton_methods' do
      context 'given "Thing"' do
        context 'and Thing has no singleton methods' do
          setup_thing

          it 'returns an empty array' do
            Implementation.new('Thing').all_singleton_methods.should be_empty
          end
        end

        context 'and Thing has a singleton method' do
          setup_thing do
            def self.alive?() end
          end

          it 'returns the singleton method in an array' do
            Implementation.new('Thing').all_singleton_methods.should eq(
              ['Thing.alive?']
            )
          end
        end
      end
    end

    describe '#all_instance_methods' do
      context 'given "Thing"' do
        context 'and Thing has no instance methods' do
          setup_thing
          
          it 'returns an empty array' do
            Implementation.new('Thing').all_instance_methods.should be_empty
          end
        end

        context 'and Thing has an instance method named "alive?"' do
          setup_thing do
            def alive?() end
          end

          it 'returns "Thing#alive?" in an array' do
            Implementation.new('Thing').all_instance_methods.should eq(
              ['Thing#alive?']
            )
          end
        end
      end
    end

    describe '#mutatees' do
      context 'given "Thing.alive?"' do
        let(:implementation) { Implementation.new('Thing.alive?') }

        it 'returns an array with one mutatee' do
          implementation.mutatees.should have(1).mutatee
          implementation.mutatees.first.should be_a(Rbx::Mutatee)
        end
      end

      context 'given "Thing#alive?"' do
        let(:implementation) { Implementation.new('Thing#alive?') }

        it 'returns an array with one mutatee' do
          implementation.mutatees.should have(1).mutatee
          implementation.mutatees.first.should be_a(Rbx::Mutatee)
        end
      end

      context 'given "Thing"' do
        context 'and Thing has no methods' do
          setup_thing

          it 'returns an empty array' do
            Implementation.new('Thing').mutatees.should be_empty
          end
        end

        context 'and Thing has a singleton and instance method' do
          setup_thing do
            def self.alive?() end
            def alive?() end
          end

          let(:implementation) { Implementation.new('Thing') }

          it 'returns an array with two mutatees' do
            implementation.should have(2).mutatees
            implementation.mutatees.each do |mutatee|
              mutatee.should be_a(Rbx::Mutatee)
            end
          end
        end
      end
    end
  end
end
