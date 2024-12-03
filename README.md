# Introduction

这是一个 vue2 版本的分页组件，用于在应用程序中实现分页功能。它的特殊之处在于使用鼠标滚轮、鼠标推拽、甚至触摸屏上下滑动时切换上一页/下一页。

# Install

```bash
npm i swiper-pagination
```

# Demo

```html
<template>
  <swiper-pagination
    :pageNum.sync="pageNum"
    :pageSize="pageSize"
    :total="total"
    @firstPage="onFirstPage"
    @lastPage="onLastPage"
    @pageChange="onPageChange"
  >
    <ul>
      <li v-for="item in items" :key="item.id">{{ item.text }}</li>
    </ul>
  </swiper-pagination>
</template>

<script>
  import swiperPagination from "swiper-pagination";

  export default {
    components: {
      "swiper-pagination": swiperPagination,
    },
    data: () => ({
      pageNum: 1,
      pageSize: 10,
      total: 0,
      items: [],
    }),
    async mounted() {
      this.items = await this.requestData();
    },
    methods: {
      requestData() {
        return new Promise((resolve) => {
          setTimeout(() => {
            resolve({
              data: [
                { id: 1, text: "item1" },
                { id: 2, text: "item2" },
                { id: 3, text: "item3" },
              ],
              total: 100,
            });
          }, 1000);
        });
      },
      onFirstPage() {
        console.log("当前是首页");
      },
      onLastPage() {
        console.log("当前是尾页");
      },
      onPageChange() {
        this.items = await this.requestData();
      },
    },
  };
</script>
```

# Document

## Props

```javascript
{
    // 当前页码
    pageNum: {
        type: Number,
        default: 1,
    },
    // 当前页数据条数
    pageSize: {
        type: Number,
        default: 10,
    },
    // 总数据条数
    total: {
        type: Number,
        default: 20,
    },
    // 支持的翻页事件，可以随意组合
    events: {
        type: Array,
        default: () => ["wheel", "drag", "touch"], // wheel：表示支持WEB端鼠标滚轮翻页；move：表示支持WEB端鼠标拖动翻页；touch：表示支持触屏拖动翻页
    },
    // 翻页时是否展示页码遮罩
    pageModal: {
        type: Boolean,
        default: true,
    },
    // 页码遮罩透明度
    pageModalOpacity: {
        type: Number,
        default: 0.35,
    },
    // 动画持续时间，单位：秒
    animationDuration: {
        type: Number,
        default: 0.4,
    },
    // 触发加载上一页/下一页的容器移动高度极限，默认0.25表示当容器上下移动超过自身高度25%时触发
    triggerLimit: {
        type: Number,
        default: 0.25,
    },
    // 上一页/下一页出现的方式
    togglePageType: {
        type: String,
        default: "slide", // slide：滑动出现；instantly：瞬间出现；
    },
},
```

# Events

```javascript
// 页码改变事件
this.$emit("pageChange", this._pageNum);
// 到达首页事件
this.$emit("firstPage");
// 到达尾页事件
this.$emit("lastPage");
```
