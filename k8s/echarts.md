# echarts

## 1.dataZoom介绍

需要在echarts.js 中引入，否则会导致添加组件属性不生效

 require('echarts/lib/component/dataZoom'); 

```
 {

                type: 'inside',//组件类型
                id: 'insideX',//组件 ID。默认不指定。指定则可用于在 option 或者 API 中引用组件。
                disabled: false,//是否停止组件功能。
                //xAxis与yAxis参见grid
                xAxisIndex: 0,//设置组件控制的x轴，如果是number表示控制一个轴，如果是Array表示控制多个轴。(控制第一个轴)
                yAxisIndex: [0, 2],//设置组件控制的y轴，如果是number表示控制一个轴，如果是Array表示控制多个轴。(控制第一个和第三个轴)
                //radiusAxis与angleAxis参见polar
                radiusAxisIndex: 0,//设置组件控制的radius轴，如果是number表示控制一个轴，如果是Array表示控制多个轴。
                angleAxisIndex: [0, 1],//设置组件控制的angle轴，如果是number 表示控制一个轴，如果是Array表示控制多个轴。
                //dataZoom 的运行原理是通过 数据过滤以及在内部设置轴的显示窗口来达到 数据窗口缩放的效果。
                //'filter'：当前数据窗口外的数据，被过滤掉。即会影响其他轴的数据范围。每个数据项，只要有一个维度在数据窗口外，整个数据项就会被过滤掉。
                // 'weakFilter'：当前数据窗口外的数据，被过滤掉。即会影响其他轴的数据范围。每个数据项，只有当全部维度都在数据窗口同侧外部，整个数据项才会被过滤掉。
                // 'empty'：当前数据窗口外的数据，被设置为空。即不会影响其他轴的数据范围。
                // 'none': 不过滤数据，只改变数轴范围。
                filterMode: 'filter',
                start: 0,//数据窗口范围的起始百分比。范围是：0 ~ 100。表示 0% ~ 100%。
                end: 100,
                startValue: 0,//数据窗口范围的起始数值(绝对数值)。如果设置了dataZoom-inside.start 则startValue失效。
                endValue: 100,
                minSpan: 0,//用于限制窗口大小的最小值（百分比值），取值范围是0 ~ 100。
                maxSpan: 100,
                //如在时间轴上可以设置为：3600 * 24 * 1000 * 5 表示 5 天。在类目轴上可以设置为5表示5个类目。
                minValueSpan: 5,//用于限制窗口大小的最小值（实际数值）。
                maxValueSpan: 10,
                orient: 'horizontal',//布局方式是横还是竖。不仅是布局方式，对于直角坐标系而言，也决定了，缺省情况控制横向数轴还是纵向数轴。
                zoomLock: true,//是否锁定选择区域（或叫做数据窗口）的大小。如果设置为 true 则锁定选择区域的大小，也就是说，只能平移，不能缩放。
                animation: true,//设置动画效果
                throttle: 100,//设置触发视图刷新的频率。单位为毫秒（ms）。
                //如果我们手动在 option 中设定了 rangeMode，那么它只在 start 和 startValue 都设置了或者 end 和 endValue 都设置了才有意义。
                // 所以通常我们没必要在 option 中指定 rangeMode。
                rangeMode: ['value', 'percent'],//rangeMode: ['value', 'percent']，表示 start 值取绝对数值，end 取百分比。
                //如何触发缩放。
                zoomOnMouseWheel: true,// 可选值为：true：表示不按任何功能键，鼠标滚轮能触发缩放。false：表示鼠标滚轮不能触发缩放。
                //如何触发数据窗口平移。
                moveOnMouseMove: true,//。可选值为：true：表示不按任何功能键，鼠标移动能触发数据窗口平移。false：表示鼠标移动不能触发平移。
                //如何触发数据窗口平移。
                moveOnMouseWheel: true,//可选值为：true：表示不按任何功能键，鼠标滚轮能触发数据窗口平移。false：表示鼠标滚轮不能触发平移。
                preventDefaultMouseMove: true//是否阻止 mousemove 事件的默认行为
            },

```

## 2.elment UI 组件添加回车键搜索

el-date-picker  添加 onchange  

```
 @change="onSearch"
```

el-input  添加 enter.native

```
@keyup.enter.native="onSearch"
```









