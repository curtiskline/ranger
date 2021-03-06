require 'test_helper'

class ShiftsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @shift = shifts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shifts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift" do
    assert_difference('Shift.count') do
      post :create, event_id: @shift.event_id, shift: {name: @shift.name, start_time: @shift.start_time + 1.day, end_time: @shift.end_time + 1.day}
    end

    assert_redirected_to event_shift_path(assigns(:event), assigns(:shift))
  end

  test "should show shift" do
    get :show, :id => @shift
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @shift
    assert_response :success
  end

  test "should update shift" do
    put :update, id: @shift, event_id: @shift.event_id, shift: {name: @shift.name, start_time: @shift.start_time + 1.day, end_time: @shift.end_time + 1.day}
    assert_redirected_to event_shift_path(assigns(:event), assigns(:shift))
  end

  test "should destroy shift" do
    assert_difference('Shift.count', -1) do
      delete :destroy, :id => @shift
    end
    assert_redirected_to event_shifts_path(assigns(:event))
  end
end
