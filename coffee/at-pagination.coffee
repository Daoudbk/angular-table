angular.module("angular-table").directive "atPagination", ["angularTableManager", (angularTableManager) ->
  {
    replace: true
    restrict: "E"

    template: "
      <div style='margin: 0px;'>
        <ul class='pagination'>
          <li ng-class='{disabled: get_current_page() <= 0}'>
            <a href='' ng-click='step_page(-#{irk_number_of_pages})'>First</a>
          </li>

          <li ng-show='show_sectioning()' ng-class='{disabled: get_current_page() <= 0}'>
            <a href='' ng-click='jump_back()'>&laquo;</a>
          </li>

          <li ng-class='{disabled: get_current_page() <= 0}'>
            <a href='' ng-click='step_page(-1)'>&lsaquo;</a>
          </li>

          <li ng-class='{active: get_current_page() == page}' ng-repeat='page in pages'>
            <a href='' ng-click='go_to_page(page)'>{{page + 1}}</a>
          </li>

          <li ng-class='{disabled: get_current_page() >= #{irk_number_of_pages} - 1}'>
            <a href='' ng-click='step_page(1)'>&rsaquo;</a>
          </li>

          <li ng-show='show_sectioning()' ng-class='{disabled: get_current_page() >= #{irk_number_of_pages} - 1}'>
            <a href='' ng-click='jump_ahead()'>&raquo;</a>
          </li>

          <li ng-class='{disabled: get_current_page() >= #{irk_number_of_pages} - 1}'>
            <a href='' ng-click='step_page(#{irk_number_of_pages})'>Last</a>
          </li>
        </ul>
      </div>"

    controller: ["$scope", "$element", "$attrs",
    ($scope, $element, $attrs) ->
      angularTableManager.register_pagination_scope($attrs.atTableId, $scope)
    ]

    scope: true

    link: ($scope, $element, $attributes) ->
      tc = angularTableManager.get_table_configuration($attributes.atTableId)

      w = new ScopeConfigWrapper($scope, tc)

      generate_page_array = (start, end) ->
        x for x in [start..end]

      set_current_page = (current_page) ->
        $scope.$parent.$eval("#{tc.current_page}=#{current_page}")

      get_number_of_pages = () ->
        $scope[irk_number_of_pages]

      set_number_of_pages = (number_of_pages) ->
        $scope[irk_number_of_pages] = number_of_pages

      update = (reset) ->
        if $scope[tc.list]
          if $scope[tc.list].length > 0
            set_number_of_pages(Math.ceil($scope[tc.list].length / w.get_items_per_page()))
            set_current_page(keep_in_bounds(w.get_current_page(), 0, get_number_of_pages() - 1))
            if $scope.show_sectioning()
              $scope.update_sectioning()
            else
              $scope.pages = generate_page_array(0, get_number_of_pages() - 1)
          else
            set_number_of_pages(1)
            $scope.pages = [0]

      keep_in_bounds = (val, min, max) ->
        val = Math.max(min, val)
        Math.min(max, val)

      $scope.show_sectioning = () ->
        tc.max_pages && get_number_of_pages() > w.get_max_pages()

      $scope.get_current_page = () ->
        w.get_current_page()

      shift_sectioning = (current_start, steps, length, upper_bound) ->
        new_start = current_start + steps
        if new_start > (upper_bound - length)
          upper_bound - length
        else if new_start < 0
          0
        else
          new_start
        $scope.pages = generate_page_array(new_start, new_start + parseInt(w.get_max_pages()) - 1)

      $scope.update_sectioning = () ->
        new_start = undefined

        if $scope.pages[0] > w.get_current_page()
          diff = $scope.pages[0] - w.get_current_page()
          shift_sectioning($scope.pages[0], -diff, w.get_max_pages(), get_number_of_pages())
        else if $scope.pages[$scope.pages.length - 1] < w.get_current_page()
          diff = w.get_current_page() - $scope.pages[$scope.pages.length - 1]
          shift_sectioning($scope.pages[0], diff, w.get_max_pages(), get_number_of_pages())
        else if $scope.pages[$scope.pages.length - 1] > (get_number_of_pages() - 1)
          diff = w.get_current_page() - $scope.pages[$scope.pages.length - 1]
          shift_sectioning($scope.pages[0], diff, w.get_max_pages(), get_number_of_pages())
        else
          $scope.pages = generate_page_array(0, parseInt(w.get_max_pages()) - 1)

      $scope.step_page = (step) ->
        step = parseInt(step)
        set_current_page(keep_in_bounds(w.get_current_page() + step, 0, get_number_of_pages() - 1))
        $scope.update_sectioning()

      $scope.go_to_page = (page) ->
        set_current_page(page)

      $scope.jump_back = () ->
        $scope.step_page(-w.get_max_pages())

      $scope.jump_ahead = () ->
        $scope.step_page(w.get_max_pages())

      update()

      $scope.$watch tc.items_per_page, () ->
        update()

      $scope.$watch tc.max_pages, () ->
        update()

      $scope.$watch tc.list, () ->
        update()

      $scope.$watch "#{tc.list}.length", () ->
        update()

  }
]
