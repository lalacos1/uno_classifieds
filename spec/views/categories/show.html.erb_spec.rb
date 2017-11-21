require 'rails_helper'

RSpec.describe 'categories/show', :type => :view do
  before(:each) do
    @category = assign(:category, Category.create!(
                                    :name => 'Name',
                                    :description => 'Description'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
  end
end

