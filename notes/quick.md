#### 自定义转换器

Java配置继承WebMvcConfigurerAdapter

重写addFormatters 返回 实现了FormatterRegistrar接口的自定义转换器



```
//决定注解是否生效
@ConditionalOnExpression
```



```
implements ApplicationContextAware
```