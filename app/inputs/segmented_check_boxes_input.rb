# frozen_string_literal: true

# Like SegmentedControlInput, but for picking several options: an Optics segmented control built from checkboxes.
#
# Usage:
#   = f.input :difficulties, as: :segmented_check_boxes, collection: [['Easy', 0], ['Hard', 2]], full_width: true
class SegmentedCheckBoxesInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def input_type
    'check_boxes'
  end

  def input_options
    options = super
    options[:item_wrapper_tag] = false
    options[:collection_wrapper_tag] = 'div'
    options[:collection_wrapper_class] = collection_wrapper_classes
    options[:item_label_class] = 'segmented-control__label'
    options
  end

  def input_html_options
    super.tap do |options|
      options[:class].delete('form-control')
    end
  end

  def input_html_classes
    super.push('segmented-control__input')
  end

  private

  def collection_wrapper_classes
    class_names(
      'segmented-control',
      'segmented-control--multiple',
      options[:class],
      "segmented-control--#{options[:size]}": options[:size].present?,
      'segmented-control--full-width': options[:full_width].present?
    )
  end
end
