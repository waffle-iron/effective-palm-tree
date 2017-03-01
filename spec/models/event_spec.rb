require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) { create(:event) }

  it { is_expected.to be_valid }

  describe '#slug' do
    subject(:slug) { event.slug }

    it { is_expected.to eq 'playshop-live' }

    context 'when an event exists with the same name' do
      before { create(:event) }

      it { is_expected.to match /\Aplayshop-live-\d+\z/ }
    end
  end

  describe '#recurrence' do
    subject(:recurrence) { event.recurrence }

    it { is_expected.not_to be_nil }
    it { is_expected.to be_an_instance_of(Montrose::Recurrence) }

    context 'for a weekly event' do
      let(:event) { create(:event, :weekly) }

      it 'is weekly' do
        expect(recurrence.to_h[:every]).to eq :week
      end

      context 'after reloading' do
        before { event.reload }

        it 'is weekly' do
          expect(recurrence.to_h[:every]).to eq :week
        end
      end
    end
  end

  describe '#starts_at' do
    subject(:starts_at) { event.reload.starts_at }

    it { is_expected.to eq event.recurrence.events.first }
  end

  describe '#ends_at' do
    subject(:ends_at) { event.reload.ends_at }

    it { is_expected.to eq event.recurrence.events.first + 1.hour }

    context 'for a repeating event' do
      let(:event) { create(:event, :repeating) }

      it { is_expected.to be_nil }
    end
  end

  describe '::between' do
    subject(:range) { Event.between(range_start, range_end) }
    let(:range_start) do
      build(:event).tap(&:valid?).starts_at.beginning_of_month
    end
    let(:range_end) { range_start + 1.month }

    it { is_expected.to include create(:event) }
    it { is_expected.to include create(:event, :repeating) }
    it { is_expected.not_to include create(:event, :old) }
    it { is_expected.to include create(:event, :old, :repeating) }
  end
end
